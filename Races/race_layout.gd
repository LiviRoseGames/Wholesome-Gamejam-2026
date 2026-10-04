extends Node2D

signal race_finished(winner: RaceHorse)

@export_group("Bush Layout")
@export var bush_scene: PackedScene
@export var bush_count := 7
@export var first_bush_y := 900.0
@export var bush_spacing := -200.0

@export_group("Horse Layout")
@export var horse_scene: PackedScene
@export var horse_count := 7
@export var race_start_x := 1000.0
@export var first_horse_y := 680.0
@export var horse_spacing := -200.0

var horses: Array[RaceHorse] = []
var player_horse: RaceHorse

var bushes: Array[RaceBush] = []

var is_race_finished := false

func _ready() -> void:
	spawn_bushes()
	spawn_horses()
	
	var game_manager := $"../GameManager"
	game_manager.player_scored.connect(_on_player_scored)

func _process(_delta: float) -> void:
	if is_race_finished:
		return
	
	for horse in horses:
		if horse.position.x <= $FinishLine.position.x:
			_on_horse_finished(horse)
			break

func _on_horse_finished(horse: RaceHorse) -> void:
	race_finished.emit(horse)
	is_race_finished = true

func _on_player_scored(points: int) -> void:
	player_horse.advance(points)

func spawn_bushes() -> void:
	for i in bush_count:
		var bush := bush_scene.instantiate() as RaceBush
		
		var y_position := first_bush_y + (i * bush_spacing)
		
		bush.position = Vector2(0.0, y_position)
		bush.start_y = y_position
		bush.variant = 1 if i % 2 == 0 else 2
		bush.z_index = (2 * bush_count) - (2 * i)
		
		$Bushes.add_child(bush)
		bushes.append(bush)

func spawn_horses() -> void:
	for i in horse_count:
		var horse := horse_scene.instantiate() as RaceHorse
		
		var y_position := first_horse_y + (i * horse_spacing)
		
		horse.position = Vector2(race_start_x, y_position)
		horse.z_index = 13 - (i * 2)
		
		$Horses.add_child(horse)
		horses.append(horse)
	
	if horses.size() > 0:
		player_horse = horses[0]
