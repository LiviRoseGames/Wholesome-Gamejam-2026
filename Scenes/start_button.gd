extends TextureButton

@export_group("Drop In")
@export var drop_distance := 1000.0
@export var drop_duration := 0.65

@export_group("Hover Glow")
@export var hover_glow_strength := 1.5
@export var glow_fade_duration := 0.12
@export var glow_color := Color(1.0, 0.85, 0.35)

@onready var button_click_sfx: AudioStreamPlayer = $"../../SFX/ButtonClickSFX"
@onready var button_hover_sfx: AudioStreamPlayer = $"../../SFX/ButtonHoverSFX"

var final_position := Vector2.ZERO
var shader_material: ShaderMaterial


func _ready() -> void:
	final_position = position
	
	shader_material = material as ShaderMaterial
	
	if shader_material != null:
		shader_material.set_shader_parameter("glow_color", glow_color)
		set_glow_strength(0.0)
	
	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)
	
	visible = false


func show_button() -> void:
	visible = true
	
	position = final_position
	position.y -= drop_distance
	
	var tween := create_tween()
	tween.tween_property(
		self,
		"position:y",
		final_position.y,
		drop_duration
	).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)


func _on_mouse_entered() -> void:
	set_glow_strength(hover_glow_strength)


func _on_mouse_exited() -> void:
	set_glow_strength(0.0)


func set_glow_strength(value: float) -> void:
	if shader_material == null:
		return
	
	var tween := create_tween()
	tween.tween_method(
		_set_glow_strength,
		shader_material.get_shader_parameter("glow_strength"),
		value,
		glow_fade_duration
	)


func _set_glow_strength(value: float) -> void:
	if shader_material != null:
		shader_material.set_shader_parameter("glow_strength", value)
