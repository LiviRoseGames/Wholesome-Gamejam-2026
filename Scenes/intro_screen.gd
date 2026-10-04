class_name IntroScreen
extends Control

@onready var start_button: Control = $StartButton
@onready var replay_button: Control = $Control/ReplayButton
@onready var end_screen: Sprite2D = $Control/EndScreen

@onready var transition_fade: TransitionFade = $"../TransitionFade"
@onready var start_label: RichTextLabel = $StartButton/StartLabel
@onready var horse_title: RichTextLabel = $Title/Wild
@onready var derby_title: RichTextLabel = $Title/Derby
@onready var carnival_title: RichTextLabel = $Title/Carnival

@export_group("Title Drop")
@export var title_drop_distance := 600.0
@export var title_drop_duration := 0.5
@export var title_drop_delay := 0.2

@export_group("Title Wave")
@export var title_wave_speed := 2.0
@export var title_wave_height := 8.0
@export var title_wave_offset := 0.8

var starting_game := false
var title_time := 0.0
var title_is_animating := true

var horse_start_position := Vector2.ZERO
var derby_start_position := Vector2.ZERO
var carnival_start_position := Vector2.ZERO


func _ready() -> void:
	visible = true
	mouse_filter = Control.MOUSE_FILTER_STOP

	transition_fade.set_progress(1.0)

	end_screen.hide()
	replay_button.mouse_filter = Control.MOUSE_FILTER_IGNORE

	horse_start_position = horse_title.position
	derby_start_position = derby_title.position
	carnival_start_position = carnival_title.position

	# Start the title words above the screen.
	horse_title.position = horse_start_position
	horse_title.position.y -= title_drop_distance

	derby_title.position = derby_start_position
	derby_title.position.y -= title_drop_distance

	carnival_title.position = carnival_start_position
	carnival_title.position.y -= title_drop_distance

	start_button.hide()
	start_title_animation()


func start_title_animation() -> void:
	var horse_tween := create_tween()
	horse_tween.tween_property(
		horse_title,
		"position:y",
		horse_start_position.y,
		title_drop_duration
	).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)

	await get_tree().create_timer(title_drop_delay).timeout

	var derby_tween := create_tween()
	derby_tween.tween_property(
		derby_title,
		"position:y",
		derby_start_position.y,
		title_drop_duration
	).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)

	await get_tree().create_timer(title_drop_delay).timeout

	var carnival_tween := create_tween()
	carnival_tween.tween_property(
		carnival_title,
		"position:y",
		carnival_start_position.y,
		title_drop_duration
	).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)

	await carnival_tween.finished

	# Now that the title has landed, bring in the Start button.
	title_is_animating = false
	start_button.show_button()


func _process(delta: float) -> void:
	if title_is_animating:
		return

	title_time += delta

	horse_title.position = horse_start_position + Vector2(
		0.0,
		sin(title_time * title_wave_speed) * title_wave_height
	)

	derby_title.position = derby_start_position + Vector2(
		0.0,
		sin(title_time * title_wave_speed + title_wave_offset) * title_wave_height
	)

	carnival_title.position = carnival_start_position + Vector2(
		0.0,
		sin(title_time * title_wave_speed + title_wave_offset * 2.0) * title_wave_height
	)


func _on_start_button_pressed() -> void:
	if starting_game:
		return

	starting_game = true
	start_button.hide()

	await transition_fade.fade_from_black()

	visible = false
	mouse_filter = Control.MOUSE_FILTER_IGNORE


func show_end_screen() -> void:
	visible = true
	mouse_filter = Control.MOUSE_FILTER_STOP

	$Title.hide()
	start_button.hide()

	end_screen.show()
	replay_button.mouse_filter = Control.MOUSE_FILTER_STOP


func _on_replay_button_pressed() -> void:
	replay_button.mouse_filter = Control.MOUSE_FILTER_IGNORE
	end_screen.hide()

	$"../LevelManager".load_level(1)

	visible = false
	mouse_filter = Control.MOUSE_FILTER_IGNORE
