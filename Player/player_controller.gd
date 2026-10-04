class_name PlayerController
extends Node

@export_group("Shot")
@export var max_shot_power := 5000.0
@export var power_multiplier := 20.0
@export var flick_threshold := 100.0

@export_group("Pickup")
@export var pickup_speed := 10.0

@export_group("References")
@export var player_table: Node2D

@export_group("Cursor")
@export var default_cursor: Texture2D
@export var holding_cursor: Texture2D
@export var default_hotspot := Vector2.ZERO
@export var holding_hotspot := Vector2(128, 0)

var ball: GameBall
var ball_hold_area: Area2D

var is_aiming := false
var holding_cursor_active := false
var previous_mouse_position := Vector2.ZERO

func _ready() -> void:
	var level_manager := $"../LevelManager"
	level_manager.level_loaded.connect(_on_level_loaded)

	update_cursor()

func _process(delta: float) -> void:
	if player_table == null:
		return
	
	var mouse_position := player_table.get_global_mouse_position()

	if not is_aiming and holding_cursor_active:
		if not is_mouse_over_ball(mouse_position):
			holding_cursor_active = false
			update_cursor()

	if is_mouse_over_ball(mouse_position) and not is_aiming:
		start_aiming()

	if not is_aiming:
		return

	var mouse_delta := mouse_position - previous_mouse_position

	if mouse_delta.length() >= flick_threshold:
		var direction := mouse_delta.normalized()

		if direction.y < 0.0:
			var power := mouse_delta.length() * power_multiplier
			power = min(power, max_shot_power)

			ball.launch(direction, power)
			is_aiming = false

			return

	var hold_position := get_clamped_hold_position(mouse_position)

	ball.global_position = ball.global_position.lerp(
		hold_position,
		pickup_speed * delta
	)

	previous_mouse_position = mouse_position

func _on_level_loaded(new_player_table: Node2D) -> void:
	player_table = new_player_table
	ball = player_table.get_node("Ball") as GameBall
	ball_hold_area = player_table.get_node("BallHoldArea") as Area2D

func update_cursor() -> void:
	if holding_cursor_active:
		Input.set_custom_mouse_cursor(
			holding_cursor,
			Input.CURSOR_ARROW,
			holding_hotspot
		)
	else:
		Input.set_custom_mouse_cursor(
			default_cursor,
			Input.CURSOR_ARROW,
			default_hotspot
		)

func is_mouse_over_ball(mouse_position: Vector2) -> bool:
	var collision_shape := (
		ball.get_node("CollisionShape2D")
		as CollisionShape2D
	)

	var shape := collision_shape.shape as CircleShape2D
	var local_mouse := collision_shape.to_local(mouse_position)

	return local_mouse.length() <= shape.radius


func start_aiming() -> void:
	if ball.is_in_play:
		return

	if ball.is_returning:
		return

	is_aiming = true
	holding_cursor_active = true

	ball.pick_up()

	previous_mouse_position = player_table.get_global_mouse_position()
	update_cursor()

func get_clamped_hold_position(mouse_position: Vector2) -> Vector2:
	var collision_shape := (
		ball_hold_area.get_node("CollisionShape2D")
		as CollisionShape2D
	)

	var shape := collision_shape.shape as RectangleShape2D

	var local_mouse := ball_hold_area.to_local(mouse_position)
	var half_size := shape.size / 2.0

	local_mouse.x = clamp(
		local_mouse.x,
		collision_shape.position.x - half_size.x,
		collision_shape.position.x + half_size.x
	)

	local_mouse.y = clamp(
		local_mouse.y,
		collision_shape.position.y - half_size.y,
		collision_shape.position.y + half_size.y
	)

	return ball_hold_area.to_global(local_mouse)
