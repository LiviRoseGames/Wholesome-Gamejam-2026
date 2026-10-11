
class_name TransitionFade
extends ColorRect

@export var transition_duration := 1.2
@export var edge_size := 0.2

@onready var shader_material: ShaderMaterial = material as ShaderMaterial


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	shader_material.set_shader_parameter("progress", 1.0)
	shader_material.set_shader_parameter("edge_size", edge_size)


func fade_to_black() -> void:
	if shader_material == null:
		return

	var tween := create_tween()
	tween.tween_method(
		set_progress,
		get_progress(),
		1.0,
		transition_duration
	).set_trans(Tween.TRANS_EXPO).set_ease(Tween.EASE_IN)

	await tween.finished


func fade_from_black() -> void:
	if shader_material == null:
		return

	var tween := create_tween()
	tween.tween_method(
		set_progress,
		get_progress(),
		0.0,
		transition_duration
	).set_trans(Tween.TRANS_EXPO).set_ease(Tween.EASE_OUT)

	await tween.finished


func get_progress() -> float:
	if shader_material == null:
		return 0.0

	return shader_material.get_shader_parameter("progress")


func set_progress(value: float) -> void:
	if shader_material == null:
		return

	shader_material.set_shader_parameter("progress", value)
