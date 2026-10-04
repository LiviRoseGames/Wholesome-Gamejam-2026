class_name GameBall
extends RigidBody2D

signal entered_hole(points: int)

@export_group("Fall")
@export var fall_delay := 2.0
@export var fall_gravity := 3000.0

var fall_timer := 0.0
var fall_velocity := 0.0

var is_in_play := false
var is_held := false
var is_falling := false

var spawn_z_index := 0
var held_z_index := 3

func _ready() -> void:
	spawn_z_index = z_index
	contact_monitor = true

func _physics_process(delta: float) -> void:
	if is_falling:
		fall_velocity += fall_gravity * delta
		global_position.y += fall_velocity * delta
		
		print(
			"FALLING — y: ",
			global_position.y,
			" velocity: ",
			fall_velocity
		)
		
		return

	if not is_in_play or is_held:
		return

	fall_timer += delta

	if fall_timer >= fall_delay:
		start_fall()

func pick_up() -> void:
	print(
		"PICK UP — falling: ",
		is_falling,
		" y: ",
		global_position.y
	)

	is_held = true
	is_in_play = false
	is_falling = false
	freeze = true

	linear_velocity = Vector2.ZERO
	angular_velocity = 0.0

	z_index = held_z_index

func launch(direction: Vector2, force: float) -> void:
	is_held = false
	is_in_play = true
	is_falling = false
	freeze = false

	z_index = held_z_index

	linear_velocity = Vector2.ZERO
	angular_velocity = 0.0

	fall_timer = 0.0

	apply_central_impulse(direction.normalized() * force)

func stop_ball() -> void:
	linear_velocity = Vector2.ZERO
	angular_velocity = 0.0

func start_fall() -> void:
	print("START FALL — y: ", global_position.y)

	is_falling = true
	is_in_play = false
	freeze = false

	linear_velocity = Vector2.ZERO
	angular_velocity = 0.0

	fall_velocity = 0.0
