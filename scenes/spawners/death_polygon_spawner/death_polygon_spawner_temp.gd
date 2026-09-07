extends Node2D

const DEATH_POLYGON: PackedScene = preload("uid://bjar86ole4cyc")
const DEATH_POLYGON_CONTAINER: PackedScene = preload("uid://3yrpbbdajl20")

# in the future, DeathPolygonContainer should be its own class
func get_spawn() -> Node2D:
	var death_polygon_container := DEATH_POLYGON_CONTAINER.instantiate()
	
	for polygon_2d: Polygon2D in get_children():
		var polygon: PackedVector2Array = polygon_2d.polygon
		for i in polygon.size():
			polygon[i] += polygon_2d.position
		
		var collision_polygon := CollisionPolygon2D.new()
		collision_polygon.polygon = polygon
		collision_polygon.build_mode = CollisionPolygon2D.BUILD_SEGMENTS

		var death_polygon: Area2D = DEATH_POLYGON.instantiate()
		death_polygon.add_child(collision_polygon)
		death_polygon_container.add_child(death_polygon)
	
	return death_polygon_container
