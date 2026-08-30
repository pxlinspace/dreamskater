class_name HookComponent extends Node2D

signal highlighted
signal unhighlighted

enum HookType {
	ORBIT,
	MAGNET,
}

@export var type: HookType
var is_highlighted: bool = false:
	set = set_is_highlighted

func set_is_highlighted(value: bool) -> void:
	if is_highlighted != value:
		if value:
			highlighted.emit()
		else:
			unhighlighted.emit()
	is_highlighted = value