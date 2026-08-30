extends Area2D


func _draw() -> void:
	for collision_polygon: CollisionPolygon2D in get_children():
		draw_colored_polygon(collision_polygon.polygon, Color.WHITE)