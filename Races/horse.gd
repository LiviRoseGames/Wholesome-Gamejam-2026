class_name RaceHorse
extends Node2D

signal selected(horse: RaceHorse)

@export var horse_name := "Horse"

@export_group("Names")
@export var horse_names: Array[String] = [
	"Biscuit",
	"Pickles",
	"Waffles",
	"Boots",
	"Pepper",
	"Clover",
	"Pudding",
	"Noodle",
	"Buttercup",
	"Pancake",
	"Nugget",
	"Tater Tot",
	"Muffin",
	"Beans",
	"Sprinkles",
	"Rusty",
	"Button",
	"Mochi",
	"Jellybean",
	"Thunder",
	"Alex",
	"Johnathan",
	"Samule",
	"Bosco",
	"Livi",
	"Choco",
	"Hatsune Miku"
	
]

@export_group("Movement")
@export var movement_speed := 300.0
@export var distance_per_point := 100.0

@export_group("Appearance")
@export var body_variants: Array[Texture2D]
@export var face_variants: Array[Texture2D]
@export var head_variants: Array[Texture2D]
@export var tarp_colors: Array[Color]

@export_group("Win Animation")
@export var win_jump_height := 100.0
@export var win_jump_distance := 1500.0
@export var win_jump_duration := 0.45
@export var win_flip_duration := 0.5
@export var win_squash_amount := 0.8
@export var win_stretch_amount := 1.15

@export_group("Selection Glow")
@export var selection_glow_strength := 100.0
@export var selection_glow_color := Color("#FFD95A")
@export var selection_glow_duration := 0.2

var selection_glow_material: ShaderMaterial
var selection_glow_tween: Tween

@onready var horse_name_label: RichTextLabel = $HorseName
@onready var body: Sprite2D = $Body/Body
@onready var tarp: Sprite2D = $Body/Tarp
@onready var head: Sprite2D = $Head/MuzzleHead
@onready var face: Sprite2D = $Head/Face
@onready var selection_area: Area2D = $SelectionArea
@onready var animation_player: AnimationPlayer = $AnimationPlayer

static var previous_variant := -1
static var used_names: Array[String] = []
static var used_name_styles: Array[int] = []

var target_x := 0.0
var is_celebrating := false
var celebration_tween: Tween

var is_hovered := false
var name_tween: Tween

var normal_head_scale := Vector2.ONE
var hover_head_scale := Vector2(1.08, 1.08)
var head_scale_tween: Tween

func _ready() -> void:
	target_x = position.x
	randomize_appearance()
	randomize_name()
	
	horse_name_label.visible = false
	horse_name_label.mouse_filter = Control.MOUSE_FILTER_IGNORE

	var original_material := tarp.material as ShaderMaterial

	if original_material != null:
		selection_glow_material = original_material.duplicate()
		tarp.material = selection_glow_material

		selection_glow_material.set_shader_parameter(
			"glow_color",
			selection_glow_color
		)

		selection_glow_material.set_shader_parameter(
			"glow_strength",
			0.0
		)
	
	selection_area.input_event.connect(_on_selection_area_input_event)

func _process(delta: float) -> void:
	update_hover()
	
	if is_celebrating:
		return
	
	if position.x > target_x:
		position.x = move_toward(
			position.x,
			target_x,
			movement_speed * delta
		)
		
		if not animation_player.is_playing():
			animation_player.play("Horse Animation")
			
	elif animation_player.is_playing():
		pass

func scale_head_to(new_scale: Vector2) -> void:
	if head_scale_tween:
		head_scale_tween.kill()

	head_scale_tween = create_tween()
	head_scale_tween.set_parallel(true)

	head_scale_tween.tween_property(
		head,
		"scale",
		new_scale,
		0.12
	).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)

	head_scale_tween.tween_property(
		face,
		"scale",
		new_scale,
		0.12
	).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)

func _on_selection_area_input_event(
	_viewport: Node,
	event: InputEvent,
	_shape_idx: int
) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			selected.emit(self)

func randomize_appearance() -> void:
	if body_variants.size() > 0:
		var variant := get_random_variant()
		
		body.texture = body_variants[variant]
		
		if head_variants.size() > variant:
			head.texture = head_variants[variant]
	
	if face_variants.size() > 0:
		face.texture = face_variants.pick_random()
	
	if tarp_colors.size() > 0:
		tarp.modulate = tarp_colors.pick_random()

func randomize_name() -> void:
	if horse_names.is_empty():
		return
	
	var available_names: Array[String] = []
	
	for name in horse_names:
		if not used_names.has(name):
			available_names.append(name)
	
	if available_names.is_empty():
		used_names.clear()
		available_names = horse_names.duplicate()
	
	horse_name = available_names.pick_random()
	used_names.append(horse_name)
	
	set_horse_name()

func set_name_visible(is_visible: bool) -> void:
	if name_tween:
		name_tween.kill()

	name_tween = create_tween()

	if is_visible:
		horse_name_label.visible = true
		horse_name_label.modulate.a = 0.0
		horse_name_label.scale = Vector2(0.85, 0.85)

		name_tween.set_parallel(true)

		name_tween.tween_property(
			horse_name_label,
			"modulate:a",
			1.0,
			0.12
		).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)

		name_tween.tween_property(
			horse_name_label,
			"scale",
			Vector2.ONE,
			0.12
		).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)

	else:
		name_tween.tween_property(
			horse_name_label,
			"modulate:a",
			0.0,
			0.1
		).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)

		await name_tween.finished

		if not is_hovered:
			horse_name_label.visible = false

func set_selected(is_selected: bool) -> void:
	if is_selected:
		set_name_visible(false)

	if selection_glow_material == null:
		return

	if selection_glow_tween:
		selection_glow_tween.kill()

	var target_strength := (
		selection_glow_strength
		if is_selected
		else 0.0
	)

	selection_glow_tween = create_tween()

	selection_glow_tween.tween_method(
		set_selection_glow,
		selection_glow_material.get_shader_parameter("glow_strength"),
		target_strength,
		selection_glow_duration
	)

func set_selection_glow(value: float) -> void:
	selection_glow_material.set_shader_parameter(
		"glow_strength",
		value
	)

func set_horse_name() -> void:
	var style := get_random_name_style()

	horse_name_label.text = style.replace(
		"{NAME}",
		horse_name
	)

func get_random_name_style() -> String:
	var styles := [
		# Bouncy
		"[center][font_size=100][wave amp=20 freq=3][color=#FFF4E6]{NAME}[/color][/wave][/font_size][/center]",

		# REALLY bouncy
		"[center][font_size=110][wave amp=35 freq=5][color=#FFD95A]{NAME}[/color][/wave][/font_size][/center]",

		# Shaky
		"[center][font_size=100][shake rate=15 level=8][color=#FFF4E6]{NAME}[/color][/shake][/font_size][/center]",

		# Extremely shaky
		"[center][font_size=90][shake rate=30 level=15][color=#FF8FA3]{NAME}[/color][/shake][/font_size][/center]",

		# Tornado
		"[center][font_size=100][tornado radius=12 freq=2][color=#8FDDEB]{NAME}[/color][/tornado][/font_size][/center]",

		# MORE tornado
		"[center][font_size=115][tornado radius=25 freq=4][color=#FFD95A]{NAME}[/color][/tornado][/font_size][/center]",

		# Rainbow
		"[center][font_size=100][rainbow freq=0.5 sat=1.0 val=1.0]{NAME}[/rainbow][/font_size][/center]",

		# Slow rainbow
		"[center][font_size=120][rainbow freq=0.2 sat=0.8 val=1.0]{NAME}[/rainbow][/font_size][/center]",

		# Pulse
		"[center][font_size=100][pulse freq=2 color=#FFD95A][color=#FFF4E6]{NAME}[/color][/pulse][/font_size][/center]",

		# Big pulse
		"[center][font_size=125][pulse freq=4 color=#FF5C8A][color=#FFF4E6]{NAME}[/color][/pulse][/font_size][/center]",

		# Wave + rainbow
		"[center][font_size=105][wave amp=15 freq=2][rainbow freq=0.7 sat=1.0 val=1.0]{NAME}[/rainbow][/wave][/font_size][/center]",

		# Shake + rainbow
		"[center][font_size=95][shake rate=18 level=7][rainbow freq=0.4 sat=1.0 val=1.0]{NAME}[/rainbow][/shake][/font_size][/center]",

		# Wave + pulse
		"[center][font_size=110][wave amp=18 freq=3][pulse freq=3 color=#FFD95A][color=#FFF4E6]{NAME}[/color][/pulse][/wave][/font_size][/center]",

		# Tornado + rainbow
		"[center][font_size=105][tornado radius=10 freq=3][rainbow freq=0.6 sat=1.0 val=1.0]{NAME}[/rainbow][/tornado][/font_size][/center]",

		# Shake + pulse
		"[center][font_size=115][shake rate=12 level=5][pulse freq=2 color=#8FDDEB][color=#FFF4E6]{NAME}[/color][/pulse][/shake][/font_size][/center]",

		# Maximum nonsense
		"[center][font_size=125][wave amp=25 freq=4][rainbow freq=0.8 sat=1.0 val=1.0]{NAME}[/rainbow][/wave][/font_size][/center]",
	]

	# Start a fresh pool when we've used every style.
	if used_name_styles.size() >= styles.size():
		used_name_styles.clear()

	var available_styles: Array[int] = []

	for i in range(styles.size()):
		if not used_name_styles.has(i):
			available_styles.append(i)

	var style_index: int = available_styles.pick_random()
	used_name_styles.append(style_index)

	return styles[style_index]

func get_random_variant() -> int:
	var variants: Array[int] = [0, 1, 3]
	
	if previous_variant == 2:
		# Previous horse was a zebra, so choose a normal horse.
		var variant: int = variants.pick_random()
		previous_variant = variant
		return variant
	
	if randf() < 0.1:
		previous_variant = 2
		return 2
	
	# Normal horse.
	var variant: int = variants.pick_random()
	previous_variant = variant
	return variant

func update_hover() -> void:
	var collision_shape := $SelectionArea/CollisionShape2D as CollisionShape2D
	var shape := collision_shape.shape as RectangleShape2D
	
	var mouse_position := get_global_mouse_position()
	var local_mouse := collision_shape.to_local(mouse_position)
	
	var half_size := shape.size / 2.0
	
	var hovering := (
		local_mouse.x >= -half_size.x
		and local_mouse.x <= half_size.x
		and local_mouse.y >= -half_size.y
		and local_mouse.y <= half_size.y
	)
	
	if hovering == is_hovered:
		return
	
	is_hovered = hovering
	
	if is_hovered:
		scale_head_to(hover_head_scale)
		set_name_visible(true)
	else:
		scale_head_to(normal_head_scale)
		set_name_visible(false)

func advance(points: int) -> void:
	target_x -= points * distance_per_point

func stop() -> void:
	target_x = position.x

func stop_at_finish(finish_x: float) -> void:
	if position.x > finish_x:
		target_x = finish_x
	else:
		target_x = position.x

func reset_horse(start_position: Vector2) -> void:
	for tween in get_tree().get_processed_tweens():
		if tween.get_valid():
			var bound_node: Node = tween.get_bound_node()
			if bound_node == self:
				tween.kill()

	is_celebrating = false
	target_x = start_position.x
	position = start_position
	rotation = 0.0
	scale = Vector2.ONE
	z_index = 19

	animation_player.stop()

func celebrate_win(target_position: Vector2) -> void:
	is_celebrating = true
	stop()
	
	# Squash before launching.
	var squash_tween := create_tween()
	squash_tween.tween_property(
		self,
		"scale",
		Vector2(1.15, 0.8),
		0.12
	).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	
	await squash_tween.finished
	
	# Flip upward and completely out of frame.
	var fly_up_tween := create_tween()
	fly_up_tween.set_parallel(true)
	
	fly_up_tween.tween_property(
		self,
		"position:y",
		-1500.0,
		0.65
	).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	
	fly_up_tween.tween_property(
		self,
		"rotation",
		rotation + TAU * 1.5,
		0.65
	).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	
	await fly_up_tween.finished

	# Stay offscreen briefly to hide the transition.
	await get_tree().create_timer(0.25).timeout

	# While the horse is offscreen, bring it in front of the race.
	z_index = 30

	# Reset it above the screen.
	position = target_position
	position.y -= 1500.0
	
	# Start the entrance upright and slightly smaller.
	rotation = 0.0
	scale = Vector2(1.5, 1.5)
	
	# Drop down and grow into its final size.
	var drop_tween := create_tween()
	drop_tween.set_parallel(true)
	
	drop_tween.tween_property(
		self,
		"position:y",
		target_position.y,
		0.75
	).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	
	drop_tween.tween_property(
		self,
		"scale",
		Vector2(2.0, 2.0),
		0.75
	).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	
	await drop_tween.finished
	
	# Make absolutely sure the final scale is 2.
	scale = Vector2(2.0, 2.0)
	
	# Bounce at the winner position.
	var bounce_tween := create_tween()
	bounce_tween.set_loops()
	
	bounce_tween.tween_property(
		self,
		"position:y",
		position.y - 30.0,
		0.3
	).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	
	bounce_tween.tween_property(
		self,
		"position:y",
		position.y,
		0.3
	).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)
