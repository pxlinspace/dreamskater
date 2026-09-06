extends Node2D

const DEATH_POLYGON: PackedScene = preload("uid://bjar86ole4cyc")

# in the future, DeathPolygonContainer should be its own class
func get_spawn() -> Node2D:
	var death_polygon_container := Node2D.new() 
	death_polygon_container.name = "DeathPolygonContainer"

	for collision_polygon: CollisionPolygon2D in get_children():
		var death_polygon: Area2D = DEATH_POLYGON.instantiate()
		death_polygon.add_child(collision_polygon.duplicate())
		death_polygon_container.add_child(death_polygon)
	
	return death_polygon_container