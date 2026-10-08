class_name LevelManager
extends Node

signal level_loaded(player_table: GameTable)
signal level_changed(level_number: int)

@export var levels: Array[PackedScene]

var current_level := 1
var current_level_scene: Node2D
var player_table: GameTable

@onready var main := get_parent()


func _ready() -> void:
	load_level(current_level)


func load_level(level_number: int) -> void:
	if level_number < 1 or level_number > levels.size():
		return

	current_level = level_number

	if current_level_scene:
		current_level_scene.queue_free()
		current_level_scene = null
		player_table = null

	current_level_scene = levels[current_level - 1].instantiate()
	current_level_scene.name = "Level"

	call_deferred("_add_level")


func _add_level() -> void:
	current_level_scene.position = Vector2(3200.0, 1080.0)

	main.add_child(current_level_scene)
	main.move_child(current_level_scene, 3)

	player_table = current_level_scene.get_node("GameTable") as GameTable

	level_loaded.emit(player_table)
	level_changed.emit(current_level)

func next_level() -> void:
	if current_level >= levels.size():
		return

	load_level(current_level + 1)


func restart_level() -> void:
	load_level(current_level)


func is_last_level() -> bool:
	return current_level >= levels.size()
