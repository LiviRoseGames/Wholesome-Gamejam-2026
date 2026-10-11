
extends CanvasLayer

signal tutorial_finished

@onready var tutorial_panel: PanelContainer = $TutorialPanel
@onready var step_title: RichTextLabel = $TutorialPanel/MarginContainer/Content/StepTitle
@onready var step_description: RichTextLabel = $TutorialPanel/MarginContainer/Content/StepDescription
@onready var next_button: Button = $TutorialPanel/MarginContainer/Content/NextButton
@onready var skip_button: Button = $TutorialPanel/MarginContainer/Content/SkipButton
@onready var tutorial_arrow: Control = $TutorialArrow
@onready var markers: Node2D = get_parent().get_node("TutorialMarkers")

var current_step := 0
var tutorial_active := true
var ball_step_started := false

var race_layout: Node
var game_manager: Node
var ball: GameBall

var tutorial_steps: Array[Dictionary] = [
	{
		"title": "Select a racer!",
		"description": "Choose the horse you want to race with!",
		"marker": "RacerMarker",
		"angle": 15.0,
		"wait_for_racer": true,
		
	},
	{
		"title": "Help your horse!",
		"description": "Sink your ball into a hole to urge your horse forward!",
		"marker": "HoleMarker",
		"angle": 30.0
	},
	{
		"title": "Yellow holes — Slow",
		"description": "Yellow holes make your horse move a 'lil.",
		"marker": "YellowHoleMarker",
		"angle": 45.0
	},
	{
		"title": "Blue holes — Fast",
		"description": "Blue holes make your horse move faster!",
		"marker": "BlueHoleMarker",
		"angle": 120.0
	},
	{
		"title": "Red holes — Fastest",
		"description": "Red holes give your horse the biggest boost!",
		"marker": "RedHoleMarker",
		"angle": 160.0
	},
	{
		"title": "Flick the ball!",
		"description": "Scoop up the ball and move your mouse quickly down the table to flick the ball!",
		"marker": "BallMarker",
		"angle": 30.0,
		"wait_for_shot": true
	}
]


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS

	next_button.pressed.connect(_on_next_pressed)
	skip_button.pressed.connect(_on_skip_pressed)

	tutorial_panel.hide()
	tutorial_arrow.set("arrow_visible", false)


func start_tutorial() -> void:
	print("Tutorial: start_tutorial() called")

	if not tutorial_active:
		print("Tutorial: already inactive")
		return

	race_layout = get_tree().get_first_node_in_group("race_layout")
	game_manager = get_tree().get_first_node_in_group("game_manager")

	print("Tutorial: RaceLayout = ", race_layout)
	print("Tutorial: GameManager = ", game_manager)

	if race_layout == null or game_manager == null:
		push_error("Tutorial could not find RaceLayout or GameManager.")
		return

	ball = game_manager.get("ball") as GameBall
	print("Tutorial: Ball = ", ball)

	if ball == null:
		push_error("Tutorial could not find the GameBall.")
		return

	#Show the panel before connecting the signals.
	tutorial_panel.show()
	print("Tutorial: panel shown")

	if not race_layout.racer_selected.is_connected(_on_racer_selected):
		race_layout.racer_selected.connect(_on_racer_selected)

	if not ball.shot_started.is_connected(_on_ball_shot_started):
		ball.shot_started.connect(_on_ball_shot_started)

	_show_step()

func _show_step() -> void:
	if current_step >= tutorial_steps.size():
		_finish_tutorial()
		return

	var step: Dictionary = tutorial_steps[current_step]

	step_title.clear()
	step_title.append_text(step["title"])

	step_description.clear()
	step_description.append_text(step["description"])

	var waiting_for_racer: bool = step.get("wait_for_racer", false)
	var waiting_for_shot: bool = step.get("wait_for_shot", false)

	next_button.visible = not waiting_for_racer and not waiting_for_shot
	skip_button.visible = not waiting_for_shot

	var marker_name: String = step["marker"]
	var has_marker := not marker_name.is_empty()

	tutorial_arrow.visible = has_marker
	tutorial_arrow.set("arrow_visible", has_marker)

	if has_marker:
		var marker := markers.get_node_or_null(marker_name) as Node2D

		if marker == null:
			push_warning("Tutorial marker not found: " + marker_name)
			return

		tutorial_arrow.set("target", marker)
		tutorial_arrow.set(
			"start_angle_degrees",
			step.get("angle", -135.0)
		)

	if waiting_for_shot and not ball_step_started:
		ball_step_started = true

		game_manager.drop_ball_into_play()


func _on_racer_selected(_horse: RaceHorse) -> void:
	if not tutorial_active or current_step != 0:
		return

	current_step = 1
	_show_step()


func _on_next_pressed() -> void:
	if not tutorial_active:
		return

	var step: Dictionary = tutorial_steps[current_step]

	if step.get("wait_for_racer", false):
		return

	if step.get("wait_for_shot", false):
		return

	current_step += 1
	_show_step()


func _on_ball_shot_started() -> void:
	if not tutorial_active or current_step != tutorial_steps.size() - 1:
		return

	# The first real shot starts the race.
	race_layout.race_started = true
	_finish_tutorial()


func _on_skip_pressed() -> void:
	if not tutorial_active:
		return

	# Restore normal race behavior if the tutorial is skipped.
	race_layout.tutorial_mode = false

	if race_layout.horse_selected:
		race_layout.race_started = true
		game_manager.drop_ball_into_play()

	_finish_tutorial()


func _finish_tutorial() -> void:
	if not tutorial_active:
		return

	tutorial_active = false
	tutorial_panel.hide()
	tutorial_arrow.set("arrow_visible", false)

	tutorial_finished.emit()
