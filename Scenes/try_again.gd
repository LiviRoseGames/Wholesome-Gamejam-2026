extends TextureButton

@export_group("Drop In")
@export var drop_distance := 500.0
@export var drop_duration := 0.45

@export_group("Hover Glow")
@export var hover_glow_strength := 1.5
@export var glow_fade_duration := 0.12
@export var glow_color := Color.WHITE

@onready var label: RichTextLabel = $TryAgainLabel

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
	mouse_filter = Control.MOUSE_FILTER_IGNORE

	label.text = "[center][font_size=75][color=#FFFFFF]✦ TRY[/color][/font_size] [font_size=76][color=#FF6B6B]AGAIN![/color][/font_size] [font_size=75][color=#FFFFFF]✦[/color][/font_size][/center]"


func show_button() -> void:
	visible = true
	mouse_filter = Control.MOUSE_FILTER_STOP

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
	if shader_material == null:
		return

	var tween := create_tween()

	tween.tween_method(
		set_glow_strength,
		shader_material.get_shader_parameter("glow_strength"),
		hover_glow_strength,
		glow_fade_duration
	)


func _on_mouse_exited() -> void:
	if shader_material == null:
		return

	var tween := create_tween()

	tween.tween_method(
		set_glow_strength,
		shader_material.get_shader_parameter("glow_strength"),
		0.0,
		glow_fade_duration
	)


func set_glow_strength(value: float) -> void:
	shader_material.set_shader_parameter("glow_strength", value)
