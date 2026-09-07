extends Hook

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var anchor: Node2D = $Anchor
@onready var circle_anim: Node2D = $Anchor/CircleAnim
@onready var hook_line: HookLine = $HookLine


func _ready() -> void:
	animation_player.seek(randf() * animation_player.get_section_end_time())


func get_type() -> Hook.Type:
	return Type.ORBIT


func highlight() -> void:
	anchor.modulate = Color.YELLOW
	circle_anim.create_circle(0.5)


func unhighlight() -> void:
	anchor.modulate = Color.WHITE


func show_line() -> void:
	hook_line.fade_in()


func hide_line() -> void:
	hook_line.fade_out()
