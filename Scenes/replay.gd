extends TextureButton

@export_group("Pop In")
@export var pop_duration := 0.35

@export_group("Wiggle")
@export var wiggle_delay_min := 2.0
@export var wiggle_delay_max := 4.0
@export var wiggle_angle_min := 4.0
@export var wiggle_angle_max := 7.0
@export var wiggle_speed_min := 0.08
@export var wiggle_speed_max := 0.14

@export_group("Hover Glow")
@export var hover_glow_strength := 1.5
@export var glow_fade_duration := 0.12
@export var glow_color := Color(1.0, 0.85, 0.35)

var shader_material: ShaderMaterial


func _ready() -> void:
	pivot_offset = size / 2.0

	shader_material = material as ShaderMaterial

	if shader_material != null:
		shader_material.set_shader_parameter("glow_color", glow_color)
		set_glow_strength(0.0)

	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)

	visible = false
	mouse_filter = Control.MOUSE_FILTER_IGNORE


func show_button() -> void:
	visible = true
	mouse_filter = Control.MOUSE_FILTER_STOP

	scale = Vector2.ZERO
	rotation = 0.0

	var pop_tween := create_tween()

	pop_tween.tween_property(
		self,
		"scale",
		Vector2.ONE,
		pop_duration
	).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)

	await pop_tween.finished
	wiggle_loop()


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


func wiggle_loop() -> void:
	while true:
		var delay := randf_range(
			wiggle_delay_min,
			wiggle_delay_max
		)

		await get_tree().create_timer(delay).timeout

		wiggle()


func wiggle() -> void:
	var angle := randf_range(
		wiggle_angle_min,
		wiggle_angle_max
	)

	var speed := randf_range(
		wiggle_speed_min,
		wiggle_speed_max
	)

	if randf() < 0.5:
		angle *= -1.0

	var shakes := randi_range(2, 3)

	var tween := create_tween()

	for i in range(shakes):
		tween.tween_property(
			self,
			"rotation",
			deg_to_rad(angle),
			speed
		).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)

		tween.tween_property(
			self,
			"rotation",
			deg_to_rad(-angle),
			speed * randf_range(0.8, 1.2)
		).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)

		angle *= randf_range(0.65, 0.85)

	tween.tween_property(
		self,
		"rotation",
		0.0,
		speed
	).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
