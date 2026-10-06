class_name ScoringHole
extends Area2D

enum HoleType {
	YELLOW,
	BLUE,
	RED
}

@export var hole_type: HoleType = HoleType.YELLOW

signal ball_scored(hole: ScoringHole)

@onready var ring: Sprite2D = $Ring

func _ready() -> void:
	_setup_hole()
	body_entered.connect(_on_body_entered)

func _setup_hole() -> void:
	match hole_type:
		HoleType.YELLOW:
			ring.modulate = Color.YELLOW
		
		HoleType.BLUE:
			ring.modulate = Color.BLUE
		
		HoleType.RED:
			ring.modulate = Color.RED

func _on_body_entered(body: Node2D) -> void:
	if body is GameBall and body.is_in_play():
		ball_scored.emit(self)

func get_points() -> int:
	match hole_type:
		HoleType.YELLOW:
			return 1
		
		HoleType.BLUE:
			return 3
		
		HoleType.RED:
			return 5
	
	return 0
