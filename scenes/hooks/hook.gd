@abstract
class_name Hook extends Area2D

enum Type {
	ORBIT,
	MAGNET,
}

@abstract func get_type() -> Type
@abstract func highlight() -> void
@abstract func unhighlight() -> void
@abstract func show_line() -> void
@abstract func hide_line() -> void