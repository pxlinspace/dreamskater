class_name HookLine extends Node2D


func _physics_process(_delta: float) -> void:
	if visible:
		queue_redraw()


func _draw() -> void:
	draw_line(Vector2.ZERO, Global.player.global_position - global_position, Color.WHITE)



func fade_in() -> void:
	show()
	var tween := create_tween()
	tween.tween_property(self, "modulate:a", 0.2, 0.15)


func fade_out() -> void:
	var tween := create_tween()
	tween.tween_property(self, "modulate:a", 0.0, 0.3)
	tween.tween_callback(hide)
