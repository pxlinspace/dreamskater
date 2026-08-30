extends Node2D


var hook_lines: Dictionary[int, HookLine] = {}
@export var player: Player


func _process(_delta: float) -> void:

	for hook in get_children():
		var player_distance_squared: float = hook.global_position.distance_squared_to(player.global_position)
		var i := hook.get_index()

		if hook_lines.has(i):
			if player_distance_squared > player.MAX_HOOK_DISTANCE_SQUARED:
				var tween := create_tween()
				tween.tween_property(hook_lines[i], "alpha", 0.0, 0.3)
				tween.tween_callback(func() -> void: hook_lines.erase(i))
		
		elif not hook_lines.has(i) and player_distance_squared <= player.MAX_HOOK_DISTANCE_SQUARED:
			var new_hook_line := HookLine.new()
			hook_lines[i] = new_hook_line
			var tween := create_tween()
			tween.tween_property(new_hook_line, "alpha", 0.2, 0.15)

	queue_redraw()


func _draw() -> void:
	for i in hook_lines:
		draw_line(player.global_position, get_child(i).global_position, Color(Color.WHITE, hook_lines[i].alpha))


class HookLine:
	var alpha: float = 0.0
