class_name GameBall
extends RigidBody2D

signal entered_hole(points: int)

var is_in_play := false
var is_held := false

var spawn_z_index := 0
var held_z_index := 3

func _ready() -> void:
	spawn_z_index = z_index

func pick_up() -> void:
	is_held = true
	is_in_play = false
	freeze = true
	
	linear_velocity = Vector2.ZERO
	angular_velocity = 0.0
	
	z_index = held_z_index

func launch(direction: Vector2, force: float) -> void:
	is_held = false
	is_in_play = true
	freeze = false
	
	z_index = held_z_index
	
	linear_velocity = Vector2.ZERO
	apply_central_impulse(direction.normalized() * force)
	
func stop_ball() -> void:
	linear_velocity = Vector2.ZERO
	angular_velocity = 0.0
