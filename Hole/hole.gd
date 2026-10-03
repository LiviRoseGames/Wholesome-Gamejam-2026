class_name ScoringHole
extends Area2D

@export var points: int = 1

signal ball_scored(points: int, hole_position: Vector2)

func _ready() -> void:
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node2D) -> void:
	if body is GameBall:
		ball_scored.emit(points, global_position)

#func consume_ball(ball: GameBall) -> void:
	#ball.freeze = true
	#ball.linear_velocity = Vector2.ZERO
	#
	#var tween := create_tween()
	#
	#tween.set_parallel(true)
	#tween.tween_property(ball, "scale", Vector2.ZERO, 0.15)
	#tween.tween_property(ball, "modulate:a", 0.0, 0.15)
	#
	#await tween.finished
	#
	#ball.visible = false
