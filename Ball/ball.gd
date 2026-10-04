class_name GameBall
extends RigidBody2D

signal entered_hole(points: int)

@export_group("Fall")
@export var fall_delay := 2.0
@export var fall_gravity := 1000.0
@export var resting_gravity_scale := 3.0

var fall_timer := 0.0
var fall_velocity := 0.0

var is_in_play := false
var is_held := false
var is_returning := false

var spawn_z_index := 0
var held_z_index := 3

func _ready() -> void:
	spawn_z_index = z_index
	contact_monitor = true
	max_contacts_reported = 1
	gravity_scale = 1.0

func _physics_process(delta: float) -> void:
	if is_returning:
		fall_velocity += fall_gravity * delta
		global_position.y += fall_velocity * delta

		return
		
	if not is_in_play or is_held:
		return
		
	fall_timer += delta
	
	if fall_timer >= fall_delay:
		start_fall()

func pick_up() -> void:
	is_held = true
	is_in_play = false
	is_returning = false
	freeze = true

	linear_velocity = Vector2.ZERO
	angular_velocity = 0.0

	gravity_scale = 1.0

	z_index = held_z_index

func launch(direction: Vector2, force: float) -> void:
	is_held = false
	is_in_play = true
	is_returning = false
	freeze = false

	gravity_scale = 1.0

	z_index = held_z_index

	linear_velocity = Vector2.ZERO
	angular_velocity = 0.0

	fall_timer = 0.0

	apply_central_impulse(direction.normalized() * force)

func stop_ball() -> void:
	linear_velocity = Vector2.ZERO
	angular_velocity = 0.0

func start_fall() -> void:
	is_returning = true
	is_in_play = false
	is_held = false

	fall_velocity = linear_velocity.y

func stop_falling() -> void:
	is_returning = false
	is_in_play = false
	is_held = false

	linear_velocity.y = fall_velocity
	angular_velocity = 0.0

	fall_velocity = 0.0
	gravity_scale = resting_gravity_scale

func _on_body_entered(body: Node) -> void:
	if body.name == "Bottom" and is_returning:
		stop_falling()
