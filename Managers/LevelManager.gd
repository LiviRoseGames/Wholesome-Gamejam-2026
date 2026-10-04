class_name LevelManager
extends Node

signal level_loaded(player_table: Node2D)
signal level_changed(level_number: int)

@export var level_tables: Array[PackedScene]

var current_level := 5
var player_table: Node2D

@onready var main := get_parent()


func _ready() -> void:
	load_level(current_level)


func load_level(level_number: int) -> void:
	if level_number < 1 or level_number > level_tables.size():
		return

	current_level = level_number

	if player_table:
		player_table.queue_free()
		player_table = null

	player_table = level_tables[current_level - 1].instantiate()
	player_table.name = "PlayerTable"

	call_deferred("_add_player_table")


func _add_player_table() -> void:

	player_table.position = Vector2(3200.0, 1080.0)

	main.add_child(player_table)
	main.move_child(player_table, 3)

	level_loaded.emit(player_table)
	level_changed.emit(current_level)


func next_level() -> void:
	if current_level >= level_tables.size():
		return

	load_level(current_level + 1)


func restart_level() -> void:
	load_level(current_level)


func is_last_level() -> bool:
	return current_level >= level_tables.size()
