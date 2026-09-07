extends Node2D

const PLAYER: PackedScene = preload("uid://ciip6eqvxyp5p")


func get_spawn() -> Player:
	var player: Player = PLAYER.instantiate()

	player.position = global_position
	player.forward_direction = Vector2(cos(rotation), sin(rotation))

	return player