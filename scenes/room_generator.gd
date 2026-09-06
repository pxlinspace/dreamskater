extends Node2D

const ROOM: PackedScene = preload("uid://tw1iwatpvj2l")

func _ready() -> void:
	hide()
	var room: Room = ROOM.instantiate()
	add_sibling.call_deferred(room)

	await room.ready
	
	for spawner in get_children():
		if not spawner.has_method("get_spawn"):
			continue
		var spawn: Node2D = spawner.get_spawn()

		if spawn is Hook:
			room.add_hook(spawn)
		elif spawn is DeathPolygon:
			room.add_death_polygon(spawn)
		elif spawn is Player:
			room.add_player(spawn)
	