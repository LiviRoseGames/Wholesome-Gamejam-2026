class_name BallHoldArea
extends Area2D

func _physics_process(_delta: float) -> void:
	for body in get_overlapping_bodies():
		if body is GameBall and body.is_returning:
			pass
