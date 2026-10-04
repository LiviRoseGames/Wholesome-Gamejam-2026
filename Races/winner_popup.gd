class_name WinnerPopup
extends Node2D

@export var drop_distance := 500.0
@export var drop_duration := 0.7
@export var horse_target_offset := Vector2(0.0, 950.0)

@onready var cloud_container: Sprite2D = $CloudContainer
@onready var winner_label: RichTextLabel = $CloudContainer/WinnerLabel

var final_position := Vector2.ZERO

func _ready() -> void:
	final_position = position
	visible = false

func get_horse_target_position() -> Vector2:
	return final_position + horse_target_offset

func show_winner(winner_name: String, player_won: bool) -> void:
	if player_won:
		winner_label.text = "[font_size=72][color=#FFD95A]Congrats![/color][/font_size]\n[font_size=64]%s won![/font_size]" % winner_name
	else:
		winner_label.text = "[font_size=72][color=#FF6B6B]Oh no![/color][/font_size]\n[font_size=64]%s won![/font_size]" % winner_name
	
	visible = true
	
	position = final_position
	position.y -= drop_distance
	
	var tween := create_tween()
	
	tween.tween_property(
		self,
		"position:y",
		final_position.y,
		drop_duration
	).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
