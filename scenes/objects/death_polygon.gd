class_name DeathPolygon extends Area2D


func _draw() -> void:
	for collision_polygon: CollisionPolygon2D in get_children():
		var points: PackedVector2Array = collision_polygon.polygon
		points.append(points[0])
		draw_polyline(points, Color("#593a4a"), 4)