extends Node2D


func _ready() -> void:
	for polygon_part in get_children():
		print(polygon_part.sub_polygons)