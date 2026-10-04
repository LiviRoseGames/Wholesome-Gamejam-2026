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

@onready var body: Sprite2D = $Body/Body
@onready var tarp: Sprite2D = $Body/Tarp
@onready var head: Sprite2D = $Head/MuzzleHead
@onready var face: Sprite2D = $Head/Face
@onready var animation_player: AnimationPlayer = $AnimationPlayer

static var previous_variant := -1
static var used_names: Array[String] = []

var target_x := 0.0

func _ready() -> void:
	target_x = position.x
	randomize_appearance()
	randomize_name()

func _process(delta: float) -> void:
	if position.x > target_x:
		position.x = move_toward(
			position.x,
			target_x,
			movement_speed * delta
		)

		if animation_player.current_animation != "Horse Animation":
			animation_player.play("Horse Animation")
	else:
		if animation_player.is_playing():
			animation_player.stop()

func randomize_appearance() -> void:
	if body_variants.size() > 0:
		var variant := get_random_variant()
		
		body.texture = body_variants[variant]
		
		if face_variants.size() > variant:
			face.texture = face_variants[variant]
		
		if head_variants.size() > variant:
			head.texture = head_variants[variant]
	
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
