@abstract
class_name Hook extends Node2D

enum Type {
	ORBIT,
	MAGNET,
}

@abstract func get_type() -> Type
@abstract func highlight() -> void
@abstract func unhighlight() -> void