extends Node

signal player_scored(points: int)

@onready var ball: GameBall = $"../PlayerTable/Ball"
@onready var ball_spawn: Marker2D = $"../PlayerTable/BallSpawn"
@onready var holes: Node2D = $"../PlayerTable/Holes"
@onready var winner_popup: WinnerPopup = $"../RaceLayout/WinnerPopup"

var player_score := 0
var is_race_finished := false


func _ready() -> void:
	for hole in holes.get_children():
		if hole is ScoringHole:
			hole.ball_scored.connect(_on_ball_scored)

	respawn_ball()

	var race_layout := $"../RaceLayout"
	race_layout.race_finished.connect(_on_race_finished)


func _on_race_finished(winner: RaceHorse) -> void:
	is_race_finished = true
	disable_ball()
	winner_popup.show_winner(winner.horse_name)


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
