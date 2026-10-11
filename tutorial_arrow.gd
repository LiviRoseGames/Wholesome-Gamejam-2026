
extends Control

@export var target: Node2D
@export var arrow_color := Color.WHITE

@export_group("Arrow Shape")
@export var line_width := 72.0
@export var head_length := 105.0
@export var head_width := 150.0

@export_group("Arrow Position")
@export_range(-180.0, 180.0, 1.0)
var start_angle_degrees := -135.0
@export var start_distance := 210.0

var arrow_visible := false


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	set_process(true)


func _process(_delta: float) -> void:
	queue_redraw()


func _draw() -> void:
	if not arrow_visible or not is_instance_valid(target):
		return

	var tip := (
		get_global_transform_with_canvas().affine_inverse()
		* target.get_global_transform_with_canvas().origin
	)

	var angle := deg_to_rad(start_angle_degrees)
	var direction := Vector2(cos(angle), sin(angle))

	var start := tip - direction * start_distance
	var base := tip - direction * head_length
	var perpendicular := Vector2(-direction.y, direction.x)

	draw_line(start, base, arrow_color, line_width, true)

	draw_colored_polygon(
		PackedVector2Array([
			tip,
			base + perpendicular * head_width * 0.5,
			base - perpendicular * head_width * 0.5
		]),
		arrow_color
	)
