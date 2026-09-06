extends Node2D

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var anchor: Node2D = $Anchor
@onready var circle_anim: Node2D = $Anchor/CircleAnim

func _ready() -> void:
	animation_player.seek(randf() * animation_player.get_section_end_time())


func _on_hook_highlighted() -> void:
	anchor.modulate = Color.YELLOW
	circle_anim.create_circle(0.5)


func _on_hook_unhighlighted() -> void:
	anchor.modulate = Color.WHITE

