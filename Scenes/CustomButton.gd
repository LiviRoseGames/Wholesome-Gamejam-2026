class_name CustomButton
extends TextureButton

@export_group("Features")
@export var hover_scale_enabled := false
@export var hover_glow_enabled := false
@export var drop_in_enabled := false
@export var pop_in_enabled := false
@export var wiggle_enabled := false
@export var start_hidden := false

@export_group("Hover Scale")
@export var hover_scale := Vector2(1.08, 1.08)
@export var hover_scale_duration := 0.12

@export_group("Hover Glow")
@export var hover_glow_strength := 1.5
@export var glow_fade_duration := 0.12
@export var glow_color := Color.WHITE

@export_group("Drop In")
@export var drop_distance := 500.0
@export var drop_duration := 0.45

@export_group("Pop In")
@export var pop_duration := 0.35

var normal_scale := Vector2.ONE
var final_position := Vector2.ZERO
var shader_material: ShaderMaterial

var hover_tween: Tween
var glow_tween: Tween
var entrance_tween: Tween


func _ready() -> void:
	normal_scale = scale
	final_position = position
	shader_material = material as ShaderMaterial

	if hover_glow_enabled and shader_material != null:
		shader_material.set_shader_parameter("glow_color", glow_color)
		_set_glow_strength(0.0)

	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)

	if start_hidden:
		hide_button()


func show_button() -> void:
	visible = true
	mouse_filter = Control.MOUSE_FILTER_STOP

	if drop_in_enabled:
		entrance_tween = GameAnimations.drop_in(
			self, final_position, drop_distance, drop_duration
		)
	elif pop_in_enabled:
		entrance_tween = GameAnimations.pop_in(
			self, normal_scale, pop_duration
		)


func hide_button() -> void:
	_kill_tween(entrance_tween)
	_kill_tween(hover_tween)
	_kill_tween(glow_tween)

	visible = false
	mouse_filter = Control.MOUSE_FILTER_IGNORE


func _on_mouse_entered() -> void:
	if hover_scale_enabled:
		_kill_tween(hover_tween)
		hover_tween = GameAnimations.scale_to(
			self, normal_scale * hover_scale, hover_scale_duration
		)

	if hover_glow_enabled:
		set_glow_strength(hover_glow_strength)


func _on_mouse_exited() -> void:
	if hover_scale_enabled:
		_kill_tween(hover_tween)
		hover_tween = GameAnimations.scale_to(
			self, normal_scale, hover_scale_duration
		)

	if hover_glow_enabled:
		set_glow_strength(0.0)


func set_glow_strength(value: float) -> void:
	if shader_material == null:
		return

	_kill_tween(glow_tween)

	var current_strength: float = shader_material.get_shader_parameter(
		"glow_strength"
	)

	glow_tween = create_tween()
	glow_tween.tween_method(
		_set_glow_strength,
		current_strength,
		value,
		glow_fade_duration
	)


func _set_glow_strength(value: float) -> void:
	if shader_material != null:
		shader_material.set_shader_parameter("glow_strength", value)


func _kill_tween(tween: Tween) -> void:
	if tween != null and tween.is_running():
		tween.kill()
