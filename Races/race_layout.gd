extends Node2D

signal race_finished(winner: RaceHorse)

@export_group("Bush Layout")
@export var bush_scene: PackedScene
@export var bush_count := 7
@export var first_bush_y := 900.0
@export var bush_spacing := -200.0

@export_group("Finish Line Layout")
@export var finish_line_x := -1080.0
@export var finish_line_y := 180.0

@export_group("Horse Layout")
@export var horse_scene: PackedScene
@export var horse_count := 7
@export var race_start_x := 1000.0
@export var first_horse_y := 680.0
@export var horse_spacing := -200.0

@export_group("AI")
@export var ai_level_min := 1
@export var ai_level_max := 10

@export var ai_check_interval_min := 0.5
@export var ai_check_interval_max := 2.0

@onready var finish_line: Node2D = $FinishLine
@onready var winner_popup: WinnerPopup = $WinnerPopup

var horses: Array[RaceHorse] = []
var player_horse: RaceHorse
#var ai_score_timers: Array[float] = []
var ai_levels: Array[int] = []
var ai_check_timers: Array[float] = []

var bushes: Array[RaceBush] = []

var is_race_finished := false

func _ready() -> void:
	spawn_bushes()
	spawn_horses()
	
	var game_manager := $"../GameManager"
	game_manager.player_scored.connect(_on_player_scored)

func _process(delta: float) -> void:
	if is_race_finished:
		return
	
	update_ai(delta)
	
	for horse in horses:
		if horse.position.x <= finish_line.position.x:
			_on_horse_finished(horse)
			break

func _on_horse_finished(horse: RaceHorse) -> void:
	is_race_finished = true
	
	for race_horse in horses:
		race_horse.stop()
		
	horse.celebrate_win(
	winner_popup.get_horse_target_position()
)
	
	race_finished.emit(horse)

func _on_player_scored(points: int) -> void:
	if is_race_finished:
		return
	
	player_horse.advance(points)

func spawn_bushes() -> void:
	for i in bush_count:
		var bush := bush_scene.instantiate() as RaceBush
		
		var y_position := first_bush_y + (i * bush_spacing)
		
		bush.position = Vector2(0.0, y_position)
		bush.start_y = y_position
		bush.variant = 1 if i % 2 == 0 else 2
		bush.z_index = 21 - (i * 3)
		
		$Bushes.add_child(bush)
		bushes.append(bush)

func spawn_horses() -> void:
	RaceHorse.previous_variant = -1
	RaceHorse.used_names.clear()
	
	for i in horse_count:
		var horse := horse_scene.instantiate() as RaceHorse
		
		var y_position := first_horse_y + (i * horse_spacing)
		
		horse.position = Vector2(race_start_x, y_position)
		horse.z_index = 19 - (i * 3)
		
		$Horses.add_child(horse)
		horses.append(horse)
		
		if i == 0:
			ai_levels.append(0)
			ai_check_timers.append(-1.0)
		else:
			ai_levels.append(
				randi_range(
					ai_level_min,
					ai_level_max
				)
			)
			
			ai_check_timers.append(
				randf_range(
					ai_check_interval_min,
					ai_check_interval_max
				)
			)
	
	if horses.size() > 0:
		player_horse = horses[0]

func update_ai(delta: float) -> void:
	for i in range(1, horses.size()):
		ai_check_timers[i] -= delta
		
		if ai_check_timers[i] > 0.0:
			continue
		
		var hole := randi_range(1, 3)
		
		var threshold := get_ai_threshold(
			ai_levels[i],
			hole
		)
		
		var roll := randi_range(1, 100)
		
		if roll <= threshold:
			horses[i].advance(hole)
		
		ai_check_timers[i] = randf_range(
			ai_check_interval_min,
			ai_check_interval_max
		)

func get_ai_threshold(ai_level: int, hole: int) -> int:
	var base_threshold := 40 + (ai_level * 6)
	
	match hole:
		1:
			return base_threshold
		3:
			return base_threshold - 10
		5:
			return base_threshold - 20
	
	return 0
