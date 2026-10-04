class_name GameBall
extends RigidBody2D

signal entered_hole(points: int)

@export_group("Fall")
@export var fall_delay := 2.0
@export var fall_gravity := 1000.0
@export var resting_gravity_scale := 3.0

@export_group("Motion Lines")
@export var motion_line_min_speed := 500.0
@export var motion_line_interval := 0.04
@export var motion_line_lifetime := 0.18
@export var motion_line_min_length := 150.0
@export var motion_line_max_length := 500.0
@export var motion_line_width := 25.0
@export var max_motion_lines := 8
@export var fall_motion_line_count := 5

@onready var motion_trail: Node2D = $"../MotionTrail"

var motion_line_timer := 0.0

var fall_timer := 0.0
var fall_velocity := 0.0

var is_in_play := false
var is_held := false
var is_returning := false

var spawn_z_index := 0
var held_z_index := 4

func _ready() -> void:
	spawn_z_index = z_index
	contact_monitor = true
	max_contacts_reported = 1
	gravity_scale = 1.0

func _physics_process(delta: float) -> void:
	$Shadow.rotation = -rotation
	$Highlight.rotation = -rotation
	update_motion_trail(delta)
	
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
	$Shadow.visible = false

func launch(direction: Vector2, force: float) -> void:
	is_held = false
	is_in_play = true
	is_returning = false
	freeze = false

	gravity_scale = 1.0

	z_index = held_z_index

	$Shadow.visible = true
	$Shadow.modulate.a = 0.0

	var shadow_tween := create_tween()
	shadow_tween.tween_property(
		$Shadow,
		"modulate:a",
		1.0,
		0.2
	)

	linear_velocity = Vector2.ZERO
	angular_velocity = 0.0

	fall_timer = 0.0

	apply_central_impulse(direction.normalized() * force)

	var spin_direction: float = -sign(direction.x)
	angular_velocity = spin_direction * force * 0.01

func stop_ball() -> void:
	linear_velocity = Vector2.ZERO
	angular_velocity = 0.0

func start_fall() -> void:
	is_returning = true
	is_in_play = false
	is_held = false

	fall_velocity = linear_velocity.y
	spawn_fall_motion_lines()

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

func update_motion_trail(delta: float) -> void:
	if is_held or not is_in_play:
		motion_line_timer = 0.0
		return

	var speed: float = linear_velocity.length()

	if speed < motion_line_min_speed:
		motion_line_timer = 0.0
		return

	motion_line_timer += delta

	if motion_line_timer < motion_line_interval:
		return

	motion_line_timer = 0.0

	spawn_motion_line(speed)

func spawn_motion_line(
	speed: float,
	ignore_limit: bool = false,
	direction_override: Vector2 = Vector2.ZERO
) -> void:
	if not ignore_limit and motion_trail.get_child_count() >= max_motion_lines:
		return

	var line: Line2D = Line2D.new()

	var direction: Vector2

	if direction_override != Vector2.ZERO:
		direction = direction_override.normalized()
	else:
		direction = linear_velocity.normalized()

	var perpendicular: Vector2 = Vector2(-direction.y, direction.x)

	var speed_ratio: float = clamp(
		speed / 3000.0,
		0.0,
		1.0
	)

	var base_length: float = lerp(
		motion_line_min_length,
		motion_line_max_length,
		speed_ratio
	)

	var line_length: float = randf_range(
		base_length * 0.7,
		base_length * 1.3
	)

	var line_width: float = randf_range(
		motion_line_width * 0.6,
		motion_line_width * 1.2
	)

	var side_offset: float = randf_range(
		-60.0,
		60.0
	)

	var back_offset: float = randf_range(
		0.0,
		80.0
	)

	var angle_offset: float = deg_to_rad(
		randf_range(-10.0, 10.0)
	)

	var line_direction: Vector2 = direction.rotated(
		angle_offset
	)

	var start_position: Vector2 = (
		global_position
		+ perpendicular * side_offset
		- direction * back_offset
	)

	var end_position: Vector2 = (
		start_position
		- line_direction * line_length
	)

	line.add_point(
		motion_trail.to_local(start_position)
	)

	line.add_point(
		motion_trail.to_local(end_position)
	)

	line.width = line_width

	var width_curve := Curve.new()
	width_curve.add_point(Vector2(0.0, 1.0))
	width_curve.add_point(Vector2(0.7, 0.7))
	width_curve.add_point(Vector2(1.0, 0.0))

	line.width_curve = width_curve

	line.default_color = Color(
		1.0,
		1.0,
		1.0,
		randf_range(0.35, 0.65)
	)

	motion_trail.add_child(line)

	var tween := create_tween()
	tween.set_parallel(true)

	tween.tween_property(
		line,
		"modulate:a",
		0.0,
		motion_line_lifetime
	)

	tween.tween_property(
		line,
		"width",
		0.0,
		motion_line_lifetime
	)

	await tween.finished

	line.queue_free()

func spawn_fall_motion_lines() -> void:
	var speed: float = max(
		abs(fall_velocity),
		motion_line_min_speed
	)

	for i in range(fall_motion_line_count):
		spawn_motion_line(
			speed,
			true,
			Vector2.DOWN
		)
