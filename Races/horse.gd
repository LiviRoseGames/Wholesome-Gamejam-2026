class_name RaceHorse
extends Node2D

@export_group("Movement")
@export var movement_speed := 300.0
@export var distance_per_point := 100.0

@onready var animation_player: AnimationPlayer = $AnimationPlayer

var target_x := 0.0

func _ready() -> void:
	target_x = position.x

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

func advance(points: int) -> void:
	target_x -= points * distance_per_point
