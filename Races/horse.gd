class_name RaceHorse
extends Node2D

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
	"Thunder"
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

@onready var body: Sprite2D = $Body/Body
@onready var tarp: Sprite2D = $Body/Tarp
@onready var head: Sprite2D = $Head/MuzzleHead
@onready var face: Sprite2D = $Head/Face
@onready var animation_player: AnimationPlayer = $AnimationPlayer

static var previous_variant := -1
static var used_names: Array[String] = []

var target_x := 0.0
var is_celebrating := false

func _ready() -> void:
	target_x = position.x
	randomize_appearance()
	randomize_name()

func _process(delta: float) -> void:
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

func advance(points: int) -> void:
	target_x -= points * distance_per_point

func stop() -> void:
	target_x = position.x

func stop_at_finish(finish_x: float) -> void:
	if position.x > finish_x:
		target_x = finish_x
	else:
		target_x = position.x

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
