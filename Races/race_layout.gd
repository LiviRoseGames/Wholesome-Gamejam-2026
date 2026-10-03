extends Node2D

@export var bush_scene: PackedScene

@export_group("Bush Layout")
@export var bush_count := 7
@export var first_bush_y := 900.0
@export var bush_spacing := -200.0

var bushes: Array[RaceBush] = []


func _ready() -> void:
	spawn_bushes()


func spawn_bushes() -> void:
	for i in bush_count:
		var bush := bush_scene.instantiate() as RaceBush

		var y_position := first_bush_y + (i * bush_spacing)

		bush.position = Vector2(0.0, y_position)
		bush.start_y = y_position
		bush.variant = 1 if i % 2 == 0 else 2
		bush.z_index = bush_count - i

		$Bushes.add_child(bush)
		bushes.append(bush)
