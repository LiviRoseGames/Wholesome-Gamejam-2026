class_name GameBall
extends RigidBody2D

signal entered_hole(points: int)

var is_in_play := false

func launch(direction: Vector2, force: float) -> void:
	is_in_play = true
	freeze = false
	linear_velocity = Vector2.ZERO
	apply_central_impulse(direction.normalized() * force)
	
func stop_ball() -> void:
	linear_velocity = Vector2.ZERO
	angular_velocity = 0.0
