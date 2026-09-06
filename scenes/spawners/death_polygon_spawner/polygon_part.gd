extends Polygon2D

# remember: polygon2d has its own get_polygons property since a single polygon2d can have multiple polygons represented
# HOWEVER. This is only useful for making the visible polygon, but not for making the collisionpolygon itself, so it can be ignored for now.

var sub_polygons: Array[PackedVector2Array]


func _ready() -> void:
	for child in get_children():
		child.hide()
	color = Color.TRANSPARENT

	sub_polygons.append(polygon)

	for polygon_difference: PolygonDifference in get_children():
		var clipped_sub_polygons: Array[PackedVector2Array] = []
		for i in sub_polygons.size():
			clipped_sub_polygons.append_array(Geometry2D.clip_polygons(sub_polygons[i], polygon_difference.polygon))
		sub_polygons = clipped_sub_polygons
	
	queue_redraw()


func _draw() -> void:
	
	for sub_polygon in sub_polygons:
		print("sub_polygon: ", sub_polygon)

		draw_colored_polygon(sub_polygon, Color(randf(), randf(), randf()))
