extends Hook

@onready var hook_line: HookLine = $HookLine
@onready var death_area: Area2D = $DeathArea
@onready var sprite_2d: Sprite2D = $Sprite2D


func _on_player_exit_area_area_exited(_area: Area2D) -> void:
	set_is_death(true)


func get_type() -> Hook.Type:
	return Type.MAGNET


func highlight() -> void:
	pass


func unhighlight() -> void:
	pass


func show_line() -> void:
	hook_line.fade_in()


func hide_line() -> void:
	hook_line.fade_out()


func set_is_death(is_death: bool) -> void:
	death_area.set_deferred("monitorable", is_death)
	sprite_2d.modulate = Color.RED if is_death else Color.GREEN
