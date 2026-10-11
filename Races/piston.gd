class_name Piston
extends AnimatableBody2D

enum Direction {
	RIGHT,
	LEFT,
	DOWN,
	UP
}

@export var direction := Direction.RIGHT

@export var extend_distance := 300.0
@export var extend_time := 0.25
@export var retract_time := 0.35
@export var pause_time := 0.5

var retracted_position: Vector2
var extended_position: Vector2


func _ready() -> void:
	retracted_position = position
	extended_position = (
		retracted_position
		+ get_direction_vector() * extend_distance
	)

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

	return Vector2.RIGHT


func start_cycle() -> void:
	while true:
		await get_tree().create_timer(pause_time).timeout

		var extend_tween := create_tween()
		extend_tween.tween_property(
			self,
			"position",
			extended_position,
			extend_time
		).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)

		await extend_tween.finished

		await get_tree().create_timer(pause_time).timeout

		var retract_tween := create_tween()
		retract_tween.tween_property(
			self,
			"position",
			retracted_position,
			retract_time
		).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)

		await retract_tween.finished
