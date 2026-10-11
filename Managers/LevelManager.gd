
class_name LevelManager
extends Node

signal level_loaded(player_table: GameTable)
signal level_changed(level_number: int)

@export_group("Game Levels")
@export var levels: Array[PackedScene]

@export_group("Scenes")
@export var intro_scene: PackedScene
@export var game_scene: PackedScene
@export var end_scene: PackedScene

var current_level := 1
var current_level_scene: Node2D
var current_game_scene: Node
var current_screen_scene: Node
var player_table: GameTable
var transitioning := false

@onready var main: Node = get_parent()
@onready var transition_fade: TransitionFade = \
	main.get_node("TransitionFade")


func _ready() -> void:
	transition_fade.set_progress(1.0)
	call_deferred("show_intro")

func show_intro() -> void:
	_clear_level()
	_clear_game_scene()
	_clear_screen()

	if intro_scene == null:
		push_error("LevelManager: Intro scene has not been assigned.")
		return

	current_screen_scene = intro_scene.instantiate()
	current_screen_scene.name = "IntroScene"
	main.add_child(current_screen_scene)
	_keep_fade_on_top()

	var intro := current_screen_scene as IntroScreen
	if intro == null:
		push_error("IntroScene must have the IntroScreen script.")
		return

	if not intro.start_requested.is_connected(start_game):
		intro.start_requested.connect(start_game)


func start_game() -> void:
	if transitioning:
		return

	transitioning = true
	await transition_fade.fade_to_black()

	_clear_screen()

	if game_scene == null:
		push_error("LevelManager: Game scene has not been assigned.")
		transitioning = false
		await transition_fade.fade_from_black()
		return

	current_game_scene = game_scene.instantiate()
	current_game_scene.name = "GameScene"
	main.add_child(current_game_scene)
	_keep_fade_on_top()

	current_level = 1
	_load_level_into_game(current_level)

	await level_loaded
	await transition_fade.fade_from_black()
	transitioning = false


func load_level(level_number: int) -> void:
	if level_number < 1 or level_number > levels.size():
		return

	current_level = level_number
	_clear_level()
	_load_level_into_game(current_level)


func _load_level_into_game(level_number: int) -> void:
	if level_number < 1 or level_number > levels.size():
		return

	_clear_level()

	current_level_scene = levels[level_number - 1].instantiate()
	current_level_scene.name = "Level"
	call_deferred("_add_level")


func _add_level() -> void:
	if not is_instance_valid(current_level_scene):
		return

	if not is_instance_valid(current_game_scene):
		return

	current_level_scene.position = Vector2(3200.0, 1080.0)
	current_game_scene.add_child(current_level_scene)

	player_table = current_level_scene.get_node("GameTable") as GameTable

	level_loaded.emit(player_table)
	level_changed.emit(current_level)


func next_level() -> void:
	if current_level < levels.size():
		load_level(current_level + 1)


func restart_level() -> void:
	load_level(current_level)


func show_end_scene() -> void:
	_clear_level()
	_clear_game_scene()
	_clear_screen()

	if end_scene == null:
		push_error("LevelManager: End scene has not been assigned.")
		return

	current_screen_scene = end_scene.instantiate()
	current_screen_scene.name = "EndScene"
	main.add_child(current_screen_scene)
	_keep_fade_on_top()

	var replay_button := current_screen_scene.find_child(
		"ReplayButton", true, false
	) as BaseButton

	if replay_button:
		if not replay_button.pressed.is_connected(replay_game):
			replay_button.pressed.connect(replay_game)
	else:
		push_warning("EndScene has no node named ReplayButton.")


func replay_game() -> void:
	if transitioning:
		return

	transitioning = true
	await transition_fade.fade_to_black()

	_clear_screen()

	if game_scene == null:
		push_error("LevelManager: Game scene has not been assigned.")
		transitioning = false
		await transition_fade.fade_from_black()
		return

	current_game_scene = game_scene.instantiate()
	current_game_scene.name = "GameScene"
	main.add_child(current_game_scene)
	_keep_fade_on_top()

	current_level = 1
	_load_level_into_game(current_level)

	await level_loaded
	await transition_fade.fade_from_black()
	transitioning = false


func is_last_level() -> bool:
	return current_level >= levels.size()


func _clear_level() -> void:
	if is_instance_valid(current_level_scene):
		current_level_scene.queue_free()

	current_level_scene = null
	player_table = null


func _clear_game_scene() -> void:
	if is_instance_valid(current_game_scene):
		current_game_scene.queue_free()

	current_game_scene = null


func _clear_screen() -> void:
	if is_instance_valid(current_screen_scene):
		current_screen_scene.queue_free()

	current_screen_scene = null


func _keep_fade_on_top() -> void:
	main.move_child(transition_fade, main.get_child_count() - 1)
