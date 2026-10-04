class_name WinnerPopup
extends Node2D

@export var drop_distance := 500.0
@export var drop_duration := 0.7
@export var horse_target_offset := Vector2(0.0, 950.0)

@onready var cloud_container: Sprite2D = $CloudContainer
@onready var winner_label: Label = $CloudContainer/WinnerLabel

var final_position := Vector2.ZERO

func _ready() -> void:
	final_position = position
	visible = false

func get_horse_target_position() -> Vector2:
	return final_position + horse_target_offset

func show_winner(winner_name: String) -> void:
	winner_label.text = (winner_name + " WINS!").to_upper()
	
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
