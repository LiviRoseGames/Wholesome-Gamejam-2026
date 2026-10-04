class_name LevelManager
extends Node

signal level_loaded(player_table: Node2D)

@export var level_tables: Array[PackedScene]

var current_level := 2

@onready var main := get_parent()

var player_table: Node2D


func _ready() -> void:
	load_level(current_level)


func load_level(level_number: int) -> void:
	if level_number < 1 or level_number > level_tables.size():
		return

	current_level = level_number

	if player_table:
		player_table.queue_free()

	player_table = level_tables[current_level - 1].instantiate()
	player_table.name = "PlayerTable"

	call_deferred("_add_player_table")


func _add_player_table() -> void:
	main.add_child(player_table)
	player_table.position = Vector2(3200.0, 1080.0)
	main.move_child(player_table, 3)

	level_loaded.emit(player_table)
