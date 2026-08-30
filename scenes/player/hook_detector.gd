extends Node2D

var previous_closest_hook: HookComponent
var max_hook_distance_squared: float


func _physics_process(_delta: float) -> void:
	var closest_hook := get_closest_hook()
	if not closest_hook:
		remove_previous_hook_highlight()
		return
	if closest_hook != previous_closest_hook:
		remove_previous_hook_highlight()
		closest_hook.is_highlighted = true
		previous_closest_hook = closest_hook


func remove_previous_hook_highlight() -> void:
	if previous_closest_hook:
		previous_closest_hook.is_highlighted = false

func get_closest_hook() -> HookComponent:
	var closest_hook: HookComponent
	var closest_hook_distance_squared: float = INF
	for hook: HookComponent in get_tree().get_nodes_in_group("hook_components"):
		var hook_distance_squared := global_position.distance_squared_to(hook.global_position)
		if hook_distance_squared <= max_hook_distance_squared and hook_distance_squared < closest_hook_distance_squared:
			closest_hook_distance_squared = hook_distance_squared
			closest_hook = hook
	return closest_hook
