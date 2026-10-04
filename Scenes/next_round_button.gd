extends TextureButton

@export var hover_scale := Vector2(1.08, 1.08)
@export var animation_duration := 0.12

var normal_scale := Vector2.ONE
var hover_tween: Tween

func _ready() -> void:
	visible = false
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	normal_scale = scale

	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)

func show_button() -> void:
	visible = true
	mouse_filter = Control.MOUSE_FILTER_STOP
	scale = normal_scale

func hide_button() -> void:
	visible = false
	mouse_filter = Control.MOUSE_FILTER_IGNORE

func _on_mouse_entered() -> void:
	if hover_tween:
		hover_tween.kill()

	hover_tween = create_tween()
	hover_tween.tween_property(
		self,
		"scale",
		normal_scale * hover_scale,
		animation_duration
	).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)

func _on_mouse_exited() -> void:
	if hover_tween:
		hover_tween.kill()

	hover_tween = create_tween()
	hover_tween.tween_property(
		self,
		"scale",
		normal_scale,
		animation_duration
	).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
