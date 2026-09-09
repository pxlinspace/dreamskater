class_name Marking extends Area2D

const POINT_DISTANCE_SQUARED: float = 400.0
var points: PackedVector2Array = []

var intersected_indices: PackedInt32Array
var intersection_indices: PackedInt32Array


func add_point(point: Vector2) -> void:
	points.append(point)
	var size := points.size()
	if size >= 5:
		add_collision_segment(size-5, size-4)


func set_last_point(point: Vector2) -> void:
	var size := points.size()
	points[size-1] = point
	if size >= 2 and point.distance_squared_to(points[size-2]) >= POINT_DISTANCE_SQUARED:
		add_point(point)


func add_collision_segment(index_a: int, index_b: int) -> void:
	var collision_shape := CollisionShape2D.new()
	var segment_shape := SegmentShape2D.new()
	segment_shape.a = points[index_a]
	segment_shape.b = points[index_b]
	collision_shape.shape = segment_shape
	call_deferred("add_child", collision_shape)


func add_intersected_marking(marking_index: int) -> void:
	intersected_indices.append(marking_index)

func add_intersection(intersection_index: int) -> void:
	intersection_indices.append(intersection_index)


func release() -> void: #i'll make this better later lol
	var size := points.size()
	if size >= 1:
		add_collision_segment(size-2, size-1)
	if size > 2:
		add_collision_segment(size-3, size-2)
	if size > 3:
		add_collision_segment(size-4, size-3)
