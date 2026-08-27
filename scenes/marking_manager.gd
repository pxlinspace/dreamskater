class_name MarkingManager extends Node2D


const POINT_DISTANCE_SQUARED: float = 100.0

@export var player: Player
var points: PackedVector2Array = []


func _ready() -> void:
	add_point()
	add_point()



func _process(_delta: float) -> void:
	var size: int = points.size()
	points[size-1] = player.global_position
	if size >= 2 and points[size-1].distance_squared_to(points[size-2]) >= POINT_DISTANCE_SQUARED:
		add_point()
	queue_redraw()


func _draw() -> void:
	if points.size() > 1:
		draw_polyline(points, Color.WHITE)


func add_point() -> void:
	points.append(player.global_position)