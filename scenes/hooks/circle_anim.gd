extends Node2D

const BASE_RADIUS: float = 8.0

var circles: Array[Circle] = []
@onready var circle_timer: Timer = $CircleTimer

func _process(_delta: float) -> void:
	queue_redraw()


func _draw() -> void:
	for circle: Circle in circles:
		draw_circle(Vector2.ZERO, circle.radius, Color(Color.WHITE, circle.alpha), false)


func _on_circle_timer_timeout() -> void:
	create_circle()

func create_circle(duration: float = 1.0) -> void:
	var circle := Circle.new()
	var tween := create_tween().set_parallel()
	tween.tween_property(circle, "alpha", 0, duration)
	tween.tween_property(circle, "radius", BASE_RADIUS + 8.0, duration)
	tween.chain().tween_callback(circles.pop_front)
	circles.append(circle)


class Circle:
	var radius: float = BASE_RADIUS
	var alpha: float = 1.0