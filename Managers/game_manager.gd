extends Node

@onready var ball: GameBall = $"../Ball"
@onready var ball_spawn: Marker2D	 = $"../BallSpawn"
@onready var holes: Node = $"../Holes"

var player_score := 0

#Part of temp Player Controls
@export var max_shot_power := 800.0
@export var power_multiplier := 3.0

var is_aiming := false
var aim_start_position := Vector2.ZERO

func _ready() -> void:
	for hole in holes.get_children():
		if hole is ScoringHole:
			hole.ball_scored.connect(_on_ball_scored)
	
	respawn_ball()

func _on_ball_scored(points: int, hole_position: Vector2) -> void:
	player_score += points
	
	print("Player scored ", points, " point(s)!")
	print("Player score: ", player_score)
	
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
	ball.freeze = true

#Temp Player Controls
func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed:
				start_aiming()
			else:
				release_shot()

func start_aiming() -> void:
	if not ball.freeze:
		return
	
	is_aiming = true
	aim_start_position = get_viewport().get_mouse_position()

func release_shot() -> void:
	if not is_aiming:
		return
	
	is_aiming = false
	
	var mouse_position := get_viewport().get_mouse_position()
	var direction := mouse_position - aim_start_position
	
	var power := direction.length() * power_multiplier
	power = min(power, max_shot_power)
	
	if power <= 10.0:
		return
	
	ball.launch(direction, power)
