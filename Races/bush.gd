class_name RaceBush
extends Node2D

@export_group("Movement")
@export var movement_amount_min := 5.0
@export var movement_amount_max := 10.0
@export var movement_speed_min := 1.0
@export var movement_speed_max := 2.0
@export var hold_time_min := 0.1
@export var hold_time_max := 0.5

@onready var bush_1: Sprite2D = $Bush1
@onready var bush_2: Sprite2D = $Bush2

var start_y := 0.0
var variant := 1


func _ready() -> void:
	_setup_appearance()

	var movement_amount := randf_range(
		movement_amount_min,
		movement_amount_max
	)

	var movement_speed := randf_range(
		movement_speed_min,
		movement_speed_max
	)

	var hold_time := randf_range(
		hold_time_min,
		hold_time_max
	)

	var start_delay := randf_range(0.0, 1.5)

	await get_tree().create_timer(start_delay).timeout

	_start_movement(
		movement_amount,
		movement_speed,
		hold_time
	)


func _setup_appearance() -> void:
	bush_1.visible = variant == 1
	bush_2.visible = variant == 2


func _start_movement(
	movement_amount: float,
	movement_speed: float,
	hold_time: float
) -> void:
	var tween := create_tween()
	tween.set_loops()

	tween.tween_property(
		self,
		"position:y",
		start_y - movement_amount,
		1.0 / movement_speed
	).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)

	tween.tween_interval(hold_time)

	tween.tween_property(
		self,
		"position:y",
		start_y + movement_amount,
		1.0 / movement_speed
	).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)

	tween.tween_interval(hold_time)
