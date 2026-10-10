
class_name GameAnimations
extends RefCounted


static func scale_to(
	node: Control,
	target_scale: Vector2,
	duration: float = 0.12,
	trans: Tween.TransitionType = Tween.TRANS_QUAD,
	ease: Tween.EaseType = Tween.EASE_OUT
) -> Tween:
	var tween := node.create_tween()
	var animation := tween.tween_property(node, "scale", target_scale, duration)
	animation.set_trans(trans)
	animation.set_ease(ease)
	return tween


static func move_to(
	node: Control,
	target_position: Vector2,
	duration: float = 0.45,
	trans: Tween.TransitionType = Tween.TRANS_QUAD,
	ease: Tween.EaseType = Tween.EASE_OUT
) -> Tween:
	var tween := node.create_tween()
	var animation := tween.tween_property(node, "position", target_position, duration)
	animation.set_trans(trans)
	animation.set_ease(ease)
	return tween

static func drop_in(
	node: Control,
	target_position: Vector2,
	drop_distance: float = 500.0,
	duration: float = 0.45
) -> Tween:
	node.position = target_position + Vector2(0.0, -drop_distance)
	return move_to(
		node,
		target_position,
		duration,
		Tween.TRANS_BACK,
		Tween.EASE_OUT
	)


static func pop_in(
	node: Control,
	target_scale: Vector2 = Vector2.ONE,
	duration: float = 0.35
) -> Tween:
	node.scale = Vector2.ZERO
	return scale_to(
		node,
		target_scale,
		duration,
		Tween.TRANS_BACK,
		Tween.EASE_OUT
	)

static func fade_property(
	node: Node,
	property: NodePath,
	target_value: float,
	duration: float = 0.12
) -> Tween:
	var tween := node.create_tween()

	tween.tween_property(
		node,
		property,
		target_value,
		duration
	)

	return tween
