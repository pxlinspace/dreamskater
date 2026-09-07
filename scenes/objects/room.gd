class_name Room extends Node2D

@onready var marking_manager: MarkingManager = $MarkingManager
@onready var obstacle_container: Node2D = $ObstacleContainer
@onready var hook_container: Node2D = $HookContainer
@onready var player_container: Node2D = $PlayerContainer


func add_hook(hook: Hook) -> void:
	hook_container.add_child(hook)


func add_obstacle(obstacle: Node2D) -> void:
	obstacle_container.add_child(obstacle)


func add_player(player: Player) -> void:
	player_container.add_child(player)
