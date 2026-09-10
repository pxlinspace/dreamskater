class_name Edge extends Area2D

const POINT_DISTANCE_SQUARED: float = 1000.0
var points: PackedVector2Array = []
var intersection_indices: PackedInt32Array = []
var point_indices_intersected: PackedInt32Array = []
var collision_segment_count := 0

var color: Color = Color(randf_range(0.5, 1.0), randf_range(0.5, 1.0), randf_range(0.5, 1.0)) #temp variable for testing
var highlighted: bool = false # temp variable for testing


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

func get_last_point(offset: int = 0) -> Vector2:
	return points[points.size() - 1 - offset]


func add_collision_segment(index_a: int, index_b: int) -> void:
	var collision_shape := CollisionShape2D.new()
	collision_shape.set_meta("point_index", mini(index_a, index_b)) #might be able to remove this later?

	var segment_shape := SegmentShape2D.new()
	segment_shape.a = points[index_a]
	segment_shape.b = points[index_b]
	collision_shape.shape = segment_shape
	collision_segment_count += 1
	call_deferred("add_child", collision_shape)


func add_intersection(intersection_index: int, point_index_intersected: int) -> void:
	intersection_indices.append(intersection_index)
	point_indices_intersected.append(point_index_intersected)
	print("point index intersected: ", point_index_intersected)


func release() -> void:
	for point_index in range(collision_segment_count, points.size() - 1):
		add_collision_segment(point_index, point_index + 1)
