extends Node

signal player_scored(points: int)

@onready var winner_popup: WinnerPopup = $"../RaceLayout/WinnerPopup"
@onready var next_round_button: TextureButton = $"../NextRoundButton"
@onready var try_again_button: TextureButton = $"../TryAgainButton"
@onready var transition_fade: TransitionFade = $"../TransitionFade"
@onready var intro_screen: IntroScreen = $"../IntroScreen"

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


func _on_level_loaded(game_table: GameTable) -> void:
	game_table.ball_out_of_bounds.connect(_on_ball_out_of_bounds)
	
	next_round_button.hide()
	try_again_button.hide()
	
	player_score = 0
	is_race_finished = false

	ball = game_table.get_node("Ball") as GameBall
	ball_spawn = game_table.get_node("BallSpawn") as Marker2D
	holes = game_table.get_node("Holes") as Node2D

	for hole in holes.get_children():
		if hole is ScoringHole:
			hole.ball_scored.connect(_on_ball_scored)

	hide_ball()

	if transition_active:
		transition_active = false
		await transition_fade.fade_from_black()
	
func _on_race_finished(winner: RaceHorse, player_won: bool) -> void:
	is_race_finished = true
	disable_ball()
	winner_popup.show_winner(winner.horse_name, player_won)

	if player_won:
		if $"../LevelManager".is_last_level():
			intro_screen.show_end_screen()
		else:
			next_round_button.show_button()
	else:
		try_again_button.show_button()

func _on_ball_scored(hole: ScoringHole) -> void:
	var points := hole.get_points()
	var hole_position := hole.global_position

	player_score += points
	player_scored.emit(points)

	ball.begin_scoring()

	call_deferred("_handle_ball_scored", hole_position)

func _on_ball_out_of_bounds() -> void:
	if is_race_finished:
		return

	if not ball.is_in_play():
		return

	ball.begin_respawn()
	await get_tree().create_timer(0.35).timeout

	var respawn_position := Vector2(
		ball.global_position.x,
		ball_spawn.global_position.y
	)

	ball.respawn_at(respawn_position)

func _handle_ball_scored(hole_position: Vector2) -> void:
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

	await respawn_ball(hole_position.x)

func hide_ball() -> void:
	ball.visible = false
	ball.freeze = true

	ball.linear_velocity = Vector2.ZERO
	ball.angular_velocity = 0.0

func drop_ball_into_play() -> void:
	ball.visible = true
	ball.modulate.a = 1.0
	ball.scale = Vector2.ONE
	ball.global_position = ball_spawn.global_position
	ball.z_index = ball.spawn_z_index
	
	ball.drop_into_play()

func disable_ball() -> void:
	ball.disable()

func respawn_ball(respawn_x: float) -> void:
	ball.begin_respawn()

	await get_tree().create_timer(0.35).timeout

	var respawn_position := Vector2(
		respawn_x,
		ball_spawn.global_position.y
	)

	ball.respawn_at(respawn_position)

func _on_try_again_button_pressed() -> void:
	try_again_button.mouse_filter = Control.MOUSE_FILTER_IGNORE
	
	transition_active = true
	await transition_fade.fade_to_black()
	$"../LevelManager".restart_level()

func _on_next_round_button_pressed() -> void:
	next_round_button.mouse_filter = Control.MOUSE_FILTER_IGNORE
	
	transition_active = true
	await transition_fade.fade_to_black()
	$"../LevelManager".next_level()
