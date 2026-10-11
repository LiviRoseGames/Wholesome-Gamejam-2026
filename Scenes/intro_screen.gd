
class_name IntroScreen
extends Control

signal start_requested

@onready var start_button: CustomButton = $StartButton
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

@onready var button_click_sfx: AudioStreamPlayer = $"../SFX/ButtonClickSFX"
@onready var button_hover_sfx: AudioStreamPlayer = $"../SFX/ButtonHoverSFX"

var starting_game := false
var title_time := 0.0
var title_is_animating := true

var horse_start_position := Vector2.ZERO
var derby_start_position := Vector2.ZERO
var carnival_start_position := Vector2.ZERO


func _ready() -> void:
	visible = true
	mouse_filter = Control.MOUSE_FILTER_STOP

	horse_start_position = horse_title.position
	derby_start_position = derby_title.position
	carnival_start_position = carnival_title.position

	horse_title.hide()
	derby_title.hide()
	carnival_title.hide()

	start_button.hide_button()
	start_title_animation()


func start_title_animation() -> void:
	horse_title.position = horse_start_position + Vector2(
		0.0, -title_drop_distance
	)
	horse_title.show()

	var horse_tween := GameAnimations.move_to(
		horse_title,
		horse_start_position,
		title_drop_duration,
		Tween.TRANS_BACK,
		Tween.EASE_OUT
	)

	await horse_tween.finished
	if not is_inside_tree():
		return

	await get_tree().create_timer(title_drop_delay).timeout
	if not is_inside_tree():
		return

	derby_title.position = derby_start_position + Vector2(
		0.0, -title_drop_distance
	)
	derby_title.show()

	var derby_tween := GameAnimations.move_to(
		derby_title,
		derby_start_position,
		title_drop_duration,
		Tween.TRANS_BACK,
		Tween.EASE_OUT
	)

	await derby_tween.finished
	if not is_inside_tree():
		return

	await get_tree().create_timer(title_drop_delay).timeout
	if not is_inside_tree():
		return

	carnival_title.position = carnival_start_position + Vector2(
		0.0, -title_drop_distance
	)
	carnival_title.show()

	var carnival_tween := GameAnimations.move_to(
		carnival_title,
		carnival_start_position,
		title_drop_duration,
		Tween.TRANS_BACK,
		Tween.EASE_OUT
	)

	await carnival_tween.finished
	if not is_inside_tree():
		return

	title_is_animating = false
	start_button.show_button()


func _process(delta: float) -> void:
	if title_is_animating or starting_game:
		return

	title_time += delta

	horse_title.position = horse_start_position + Vector2(
		0.0,
		sin(title_time * title_wave_speed) * title_wave_height
	)

	derby_title.position = derby_start_position + Vector2(
		0.0,
		sin(title_time * title_wave_speed + title_wave_offset)
			* title_wave_height
	)

	carnival_title.position = carnival_start_position + Vector2(
		0.0,
		sin(title_time * title_wave_speed + title_wave_offset * 2.0)
			* title_wave_height
	)


func _on_start_button_pressed() -> void:
	if starting_game:
		return

	starting_game = true
	title_is_animating = true
	start_button.disabled = true

	start_requested.emit()


func play_exit_animations() -> void:
	var exit_position := Vector2(0.0, -title_drop_distance)

	var horse_tween := GameAnimations.move_to(
		horse_title,
		horse_title.position + exit_position,
		title_drop_duration,
		Tween.TRANS_QUAD,
		Tween.EASE_IN
	)

	var derby_tween := GameAnimations.move_to(
		derby_title,
		derby_title.position + exit_position,
		title_drop_duration,
		Tween.TRANS_QUAD,
		Tween.EASE_IN
	)

	var carnival_tween := GameAnimations.move_to(
		carnival_title,
		carnival_title.position + exit_position,
		title_drop_duration,
		Tween.TRANS_QUAD,
		Tween.EASE_IN
	)

	var button_tween := GameAnimations.move_to(
		start_button,
		start_button.position + Vector2(
			0.0, -start_button.drop_distance
		),
		title_drop_duration,
		Tween.TRANS_QUAD,
		Tween.EASE_IN
	)

	await horse_tween.finished
	await derby_tween.finished
	await carnival_tween.finished
	await button_tween.finished
