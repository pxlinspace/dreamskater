class_name MarkingManager extends Node2D


const POINT_DISTANCE_SQUARED: float = 100.0

# var points: PackedVector2Array = []
# Note: I currently have a system that draws individual markings, but later I oughta
# switch to a point system to account for shapes made up of multiple markings
var markings: Array[PackedVector2Array] = []


func _ready() -> void:
	await SignalBus.player_ready
	Global.player.hooked.connect(_on_player_hooked)


func _process(_delta: float) -> void:
	if Global.player.state == Player.State.HOOKED:
		queue_redraw()
		var i: int = markings.size()-1
		var j: int = markings[i].size()-1
		markings[i][j] = Global.player.global_position
		if markings[i].size() >= 2 and markings[i][j].distance_squared_to(markings[i][j - 1]) >= POINT_DISTANCE_SQUARED:
			add_point()


func _draw() -> void:
	for points: PackedVector2Array in markings:
		if points.size() > 1:
			draw_polyline(points, Color.WHITE, 2)


func _on_player_hooked() -> void:
	markings.append([])
	add_point()
	add_point()


func add_point() -> void:
	markings[markings.size()-1].append(Global.player.global_position)
