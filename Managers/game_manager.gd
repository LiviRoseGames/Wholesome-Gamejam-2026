extends Node

signal player_scored(points: int)

@onready var player_table: Node2D = $"../PlayerTable"
@onready var ball: GameBall = $"../PlayerTable/Ball"
@onready var ball_spawn: Marker2D = $"../PlayerTable/BallSpawn"
@onready var ball_hold_area: Area2D = $"../PlayerTable/BallHoldArea"
@onready var holes: Node2D = $"../PlayerTable/Holes"
@onready var winner_popup: WinnerPopup = $"../RaceLayout/WinnerPopup"

var player_score := 0

#Part of temp Player Controls
@export var max_shot_power := 5000.0
@export var power_multiplier := 20.0
@export var flick_threshold := 100.0

var previous_mouse_position := Vector2.ZERO
var just_picked_up := false
var is_race_finished := false

func _ready() -> void:
	for hole in holes.get_children():
		if hole is ScoringHole:
			hole.ball_scored.connect(_on_ball_scored)
	
	respawn_ball()
	
	var race_layout := $"../RaceLayout"
	race_layout.race_finished.connect(_on_race_finished)

func _process(_delta: float) -> void:
	if is_race_finished:
		return
	
	if not ball.is_held:
		return
	
	var mouse_position := player_table.get_global_mouse_position()
	
	if just_picked_up:
		previous_mouse_position = mouse_position
		just_picked_up = false
		return
	
	var hold_position := get_clamped_hold_position(mouse_position)
	ball.global_position = hold_position
	
	var mouse_delta := mouse_position - previous_mouse_position
	
	if mouse_delta.length() >= flick_threshold:
		var direction := mouse_delta.normalized()
		
		if direction.y < 0.0:
			var power := mouse_delta.length() * power_multiplier
			power = min(power, max_shot_power)
			
			ball.launch(direction, power)
			return
	
	previous_mouse_position = mouse_position

func _on_race_finished(winner: RaceHorse) -> void:
	is_race_finished = true
	disable_ball()
	winner_popup.show_winner(winner.horse_name)

func _on_ball_scored(points: int, hole_position: Vector2) -> void:
	player_score += points
	player_scored.emit(points)
	
	call_deferred("_handle_ball_scored", hole_position)

func _handle_ball_scored(hole_position: Vector2) -> void:
	ball.freeze = true
	ball.linear_velocity = Vector2.ZERO
	ball.angular_velocity = 0.0
	
	var tween := create_tween()
	tween.set_parallel(true)
	
	tween.tween_property(
		ball,
		"global_position",
		hole_position,
		0.25
	).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	
	tween.tween_property(
		ball,
		"scale",
		Vector2.ZERO,
		0.25
	).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	
	await tween.finished
	
	respawn_ball()

func respawn_ball() -> void:
	ball.visible = true
	ball.modulate.a = 1.0
	ball.scale = Vector2.ONE
	
	ball.global_position = ball_spawn.global_position
	
	ball.linear_velocity = Vector2.ZERO
	ball.angular_velocity = 0.0
	
	ball.is_in_play = false
	ball.is_held = false
	ball.freeze = true
	
	ball.z_index = ball.spawn_z_index

#Temp Player Controls
func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			pick_up_ball()

func pick_up_ball() -> void:
	if is_race_finished:
		return
	
	if not ball.freeze:
		return
	
	var mouse_position := player_table.get_global_mouse_position()
	
	if mouse_position.distance_to(ball.global_position) > 50.0:
		return
	
	ball.pick_up()
	previous_mouse_position = mouse_position
	just_picked_up = true

func disable_ball() -> void:
	ball.is_held = false
	ball.is_in_play = false
	ball.freeze = true
	ball.linear_velocity = Vector2.ZERO
	ball.angular_velocity = 0.0

func get_clamped_hold_position(mouse_position: Vector2) -> Vector2:
	var collision_shape := ball_hold_area.get_node("CollisionShape2D") as CollisionShape2D
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
