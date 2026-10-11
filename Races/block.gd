class_name Block
extends AnimatableBody2D

enum Direction {
	STATIONARY,
	RIGHT,
	LEFT,
	DOWN,
	UP
}

@export var direction := Direction.STATIONARY
@export var move_distance := 200.0
@export var move_time := 1.0
@export var pause_time := 0.5

@onready var block_moving_sfx: AudioStreamPlayer = $BlockMovingSFX

var start_position: Vector2
var end_position: Vector2

func _ready() -> void:
	start_position = position
	end_position = start_position + get_direction_vector() * move_distance
	
	if direction != Direction.STATIONARY:
		start_cycle()

func get_direction_vector() -> Vector2:
	match direction:
		Direction.RIGHT:
			return Vector2.RIGHT
		Direction.LEFT:
			return Vector2.LEFT
		Direction.DOWN:
			return Vector2.DOWN
		Direction.UP:
			return Vector2.UP
	return Vector2.ZERO

func start_cycle() -> void:
	while true:
		await get_tree().create_timer(pause_time).timeout
		block_moving_sfx.play()

		var move_out := create_tween()
		move_out.tween_property(
			self,
			"position",
			end_position,
			move_time
		).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN_OUT)

		await move_out.finished

		await get_tree().create_timer(pause_time).timeout

		var move_back := create_tween()
		block_moving_sfx.play()
		move_back.tween_property(
			self,
			"position",
			start_position,
			move_time
		).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN_OUT)

		await move_back.finished
