class_name TransitionFade
extends ColorRect

@export var transition_duration := 1.2
@export var edge_size := 0.2

@onready var shader_material: ShaderMaterial = material as ShaderMaterial


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE

	shader_material.set_shader_parameter("progress", 0.0)
	shader_material.set_shader_parameter("edge_size", edge_size)


func fade_to_black() -> void:
	var tween := create_tween()

	tween.tween_method(
		set_progress,
		0.0,
		1.0,
		transition_duration
	).set_trans(Tween.TRANS_EXPO).set_ease(Tween.EASE_IN)

	await tween.finished


func fade_from_black() -> void:
	var tween := create_tween()

	tween.tween_method(
		set_progress,
		1.0,
		0.0,
		transition_duration
	).set_trans(Tween.TRANS_EXPO).set_ease(Tween.EASE_OUT)

	await tween.finished


func set_progress(value: float) -> void:
	shader_material.set_shader_parameter("progress", value)
