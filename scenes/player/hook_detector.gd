extends Area2D


var previous_closest_hook: Hook


func _physics_process(_delta: float) -> void:
	var closest_hook := get_closest_hook()
	if not closest_hook:
		remove_previous_hook_highlight()
	elif closest_hook != previous_closest_hook:
		remove_previous_hook_highlight()
		closest_hook.highlight()
		previous_closest_hook = closest_hook


func remove_previous_hook_highlight() -> void:
	if previous_closest_hook:
		previous_closest_hook.unhighlight()


func get_closest_hook() -> Hook:
	var closest_hook: Hook
	var closest_hook_distance_squared: float = INF
	for hook: Hook in get_overlapping_areas():
		var hook_distance_squared := global_position.distance_squared_to(hook.global_position)
		if hook_distance_squared < closest_hook_distance_squared:
			closest_hook_distance_squared = hook_distance_squared
			closest_hook = hook
	return closest_hook


func _on_area_entered(hook: Hook) -> void:
	hook.show_line()


func _on_area_exited(hook: Hook) -> void:
	hook.hide_line()
