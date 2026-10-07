class_name GameBall
extends RigidBody2D

signal shot_started

@export_group("Motion Lines")
@export var motion_line_min_speed := 500.0
@export var motion_line_interval := 0.04
@export var motion_line_lifetime := 0.18
@export var motion_line_min_length := 150.0
@export var motion_line_max_length := 500.0
@export var motion_line_width := 25.0
@export var max_motion_lines := 8

@onready var motion_trail: Node2D = $"../MotionTrail"

const OBSTACLE_LAYER := 4

var motion_line_timer := 0.0

var spawn_z_index := 0
var held_z_index := 4


#~~~~~~~~~~~~~~~~~~ STATE MACHINE CODE ~~~~~~~~~~~~~~~~~~
enum State {
	READY,
	HELD,
	IN_PLAY,
	SCORING,
	RESPAWNING,
	SPAWNING
}

var state := State.READY


func set_state(new_state: State, reason: String = "") -> void:
	if state == new_state:
		return

	print(
		"BALL STATE: ",
		State.keys()[state],
		" -> ",
		State.keys()[new_state],
		" | ",
		reason,
		" | position: ",
		global_position,
		" | velocity: ",
		linear_velocity
	)

	state = new_state

	match state:
		State.IN_PLAY:
			set_obstacle_collision(true)

		_:
			set_obstacle_collision(false)

func is_ready() -> bool:
	return state == State.READY


func is_held() -> bool:
	return state == State.HELD


func is_in_play() -> bool:
	return state == State.IN_PLAY


func is_scoring() -> bool:
	return state == State.SCORING


func is_respawning() -> bool:
	return state == State.RESPAWNING


func is_spawning() -> bool:
	return state == State.SPAWNING


func is_pickup_available() -> bool:
	return is_ready() or is_spawning()


func _ready() -> void:
	spawn_z_index = z_index
	contact_monitor = true
	max_contacts_reported = 1
	gravity_scale = 1.0


func _physics_process(delta: float) -> void:
	$Shadow.rotation = -rotation
	$Highlight.rotation = -rotation
	update_motion_trail(delta)

func set_obstacle_collision(enabled: bool) -> void:
	if enabled:
		collision_mask |= 1 << (OBSTACLE_LAYER - 1)
	else:
		collision_mask &= ~(1 << (OBSTACLE_LAYER - 1))

func drop_into_play() -> void:
	set_state(State.READY, "ball dropped into play")
	freeze = false

	linear_velocity = Vector2.ZERO
	angular_velocity = 0.0
	gravity_scale = 1.0


func pick_up() -> void:
	set_state(State.HELD, "player picked up ball")
	freeze = true

	linear_velocity = Vector2.ZERO
	angular_velocity = 0.0

	gravity_scale = 1.0

	z_index = held_z_index
	$Shadow.visible = false


func launch(direction: Vector2, force: float) -> void:
	set_state(State.IN_PLAY, "ball launched")
	shot_started.emit()

	freeze = false
	gravity_scale = 1.0
	z_index = held_z_index
	$Shadow.visible = true
	$Shadow.modulate.a = 0.0

	var shadow_tween := create_tween()
	shadow_tween.tween_property($Shadow, "modulate:a", 1.0, 0.2)

	linear_velocity = Vector2.ZERO
	angular_velocity = 0.0

	apply_central_impulse(direction.normalized() * force)

	var spin_direction: float = -sign(direction.x)
	angular_velocity = spin_direction * force * 0.01

func disable() -> void:
	freeze = true
	linear_velocity = Vector2.ZERO
	angular_velocity = 0.0


func return_to_ready() -> void:
	set_state(State.READY, "ball reached Bottom")


func respawn_at(position: Vector2) -> void:
	set_state(State.SPAWNING, "respawn started")

	scale = Vector2.ONE
	global_position = position

	linear_velocity = Vector2.ZERO
	angular_velocity = 0.0

	freeze = false
	gravity_scale = 1.0
	z_index = spawn_z_index


func recover_from_out_of_bounds() -> void:
	if not is_in_play():
		return

	begin_respawn()


func begin_scoring() -> void:
	set_state(State.SCORING, "ball entered scoring hole")
	set_deferred("freeze", true)

	linear_velocity = Vector2.ZERO
	angular_velocity = 0.0


func begin_respawn() -> void:
	set_state(State.RESPAWNING, "respawn process started")


#~~~~~~~~~~~~~~~~~~ MOTION TRAIL CODE ~~~~~~~~~~~~~~~~~~
func update_motion_trail(delta: float) -> void:
	if not is_in_play():
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
