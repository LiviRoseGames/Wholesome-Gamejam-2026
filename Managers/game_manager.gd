extends Node

signal player_scored(points: int)

@onready var winner_popup: WinnerPopup = $"../RaceLayout/WinnerPopup"
@onready var next_round_button: TextureButton = $"../NextRoundButton"
@onready var try_again_button: TextureButton = $"../TryAgainButton"
@onready var transition_fade: TransitionFade = $"../TransitionFade"

var ball: GameBall
var ball_spawn: Marker2D
var holes: Node2D

var player_score := 0
var is_race_finished := false
var transition_active := false

func _ready() -> void:
	var level_manager := $"../LevelManager"
	level_manager.level_loaded.connect(_on_level_loaded)

	var race_layout := $"../RaceLayout"
	race_layout.race_finished.connect(_on_race_finished)


func _on_level_loaded(new_player_table: Node2D) -> void:
	next_round_button.hide()
	try_again_button.hide()
	
	player_score = 0
	is_race_finished = false

	ball = new_player_table.get_node("Ball") as GameBall
	ball_spawn = new_player_table.get_node("BallSpawn") as Marker2D
	holes = new_player_table.get_node("Holes") as Node2D

	for hole in holes.get_children():
		if hole is ScoringHole:
			hole.ball_scored.connect(_on_ball_scored)

	respawn_ball()

	if transition_active:
		transition_active = false
		await transition_fade.fade_from_black()

func _on_race_finished(winner: RaceHorse, player_won: bool) -> void:
	is_race_finished = true
	disable_ball()
	winner_popup.show_winner(winner.horse_name, player_won)

	if player_won:
		next_round_button.show_button()
	else:
		try_again_button.show_button()

func _on_ball_scored(points: int, hole_position: Vector2) -> void:
	player_score += points
	player_scored.emit(points)

	call_deferred("_handle_ball_scored", hole_position)


func _handle_ball_scored(hole_position: Vector2) -> void:
	ball.freeze = true
	ball.linear_velocity = Vector2.ZERO
	ball.angular_velocity = 0.0

	var tween := create_tween()
	tween.set_parallel(true)

	tween.tween_property(
		ball,
		"global_position",
		hole_position,
		0.25
	).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)

	tween.tween_property(
		ball,
		"scale",
		Vector2.ZERO,
		0.25
	).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)

	await tween.finished

	release_ball_from_hole(hole_position)

func release_ball_from_hole(hole_position: Vector2) -> void:
	ball.global_position = hole_position
	ball.scale = Vector2.ONE

	ball.linear_velocity = Vector2.ZERO
	ball.angular_velocity = 0.0

	ball.fall_velocity = 0.0
	ball.is_returning = true
	ball.is_in_play = false
	ball.is_held = false
	ball.freeze = false

	ball.z_index = ball.spawn_z_index - 1


func respawn_ball() -> void:
	ball.visible = true
	ball.modulate.a = 1.0
	ball.scale = Vector2.ONE

	ball.global_position = ball_spawn.global_position

	ball.linear_velocity = Vector2.ZERO
	ball.angular_velocity = 0.0

	ball.is_in_play = false
	ball.is_held = false
	ball.freeze = true

	ball.z_index = ball.spawn_z_index


func disable_ball() -> void:
	ball.is_held = false
	ball.is_in_play = false
	ball.freeze = true

	ball.linear_velocity = Vector2.ZERO
	ball.angular_velocity = 0.0

func _on_try_again_button_pressed() -> void:
	transition_active = true
	await transition_fade.fade_to_black()
	$"../LevelManager".restart_level()

func _on_next_round_button_pressed() -> void:
	transition_active = true
	await transition_fade.fade_to_black()
	$"../LevelManager".next_level()
