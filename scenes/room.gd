class_name Room extends Node2D

@onready var hook_container: Node2D = $HookContainer
@onready var death_polygon_container: Node2D = $DeathPolygonContainer
@onready var player_container: Node2D = $PlayerContainer


func add_hook(hook: Hook) -> void:
	hook_container.add_child(hook)


func add_death_polygon(death_polygon: DeathPolygon) -> void:
	death_polygon_container.add_child(death_polygon)


func add_player(player: Player) -> void:
	player_container.add_child(player)
