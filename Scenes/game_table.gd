class_name GameTable
extends Node2D

signal ball_out_of_bounds

@export_group("Ball Bounds")
@export var bounds_size := Vector2(1280.0, 2160.0)
@export var bounds_margin := 100.0

@export var missed_shot_grace_time := 0.15

var shot_timer := 0.0

@onready var ball: GameBall = $Ball
@onready var ball_hold_area: Area2D = $BallHoldArea

func _physics_process(delta: float) -> void:
	if not ball.is_in_play():
		shot_timer = 0.0
		return

	shot_timer += delta

	var ball_in_hold_area := ball_hold_area.overlaps_body(ball)

	if (
		shot_timer >= missed_shot_grace_time
		and ball_in_hold_area
		and ball.linear_velocity.y >= 0.0
	):
		ball.return_to_ready()
		return

	if is_ball_out_of_bounds():
		ball_out_of_bounds.emit()

func is_ball_out_of_bounds() -> bool:
	var local_position := to_local(ball.global_position)
	var half_size := bounds_size / 2.0

	return (
		local_position.x < -half_size.x - bounds_margin
		or local_position.x > half_size.x + bounds_margin
		or local_position.y < -half_size.y - bounds_margin
		or local_position.y > half_size.y + bounds_margin
	)
