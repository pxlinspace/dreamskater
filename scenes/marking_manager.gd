class_name MarkingManager extends Node2D


const POINT_DISTANCE_SQUARED: float = 100.0

@export var player: Player
var points: PackedVector2Array = []


func _ready() -> void:
	player.hooked.connect(_on_player_hooked)
	player.unhooked.connect(_on_player_unhooked)


func _process(_delta: float) -> void:
	if player.state == player.State.HOOKED:
		queue_redraw()
		var size: int = points.size()
		points[size-1] = player.global_position
		if size >= 2 and points[size-1].distance_squared_to(points[size-2]) >= POINT_DISTANCE_SQUARED:
			add_point()


func _draw() -> void:
	if points.size() > 1:
		draw_polyline(points, Color.WHITE, 2)


func _on_player_hooked() -> void:
	add_point()
	add_point()


func _on_player_unhooked() -> void:
	pass


func add_point() -> void:
	points.append(player.global_position)