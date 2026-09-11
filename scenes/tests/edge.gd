class_name Edge extends Area2D

const EDGE: PackedScene = preload("uid://cqqqfea8cod36")

const POINT_DISTANCE_SQUARED: float = 1000.0

var points: PackedVector2Array = []
var collision_segment_count := 0

var main_half: HalfEdge = HalfEdge.new()
var twin_half: HalfEdge = HalfEdge.new()

var color: Color = Color(randf_range(0.5, 1.0), randf_range(0.5, 1.0), randf_range(0.5, 1.0)) #temp variable for testing
var highlighted: bool = false # temp variable for testing


static func link_half_edges(half_1: HalfEdge, half_2: HalfEdge) -> void:
	if half_1 == null or half_2 == null:
		return
	half_1.next = half_2
	half_2.prev = half_1


func _init() -> void:
	main_half.twin = twin_half
	twin_half.twin = main_half


func add_point(point: Vector2) -> void:
	points.append(point)
	var size := points.size()
	if size >= 5:
		add_collision_segment(size-5, size-4)


func set_last_point(point: Vector2, has_inbetween_points: bool = true) -> void:
	var size := points.size()
	points[size-1] = point
	if has_inbetween_points and size >= 2 and point.distance_squared_to(points[size-2]) >= POINT_DISTANCE_SQUARED:
		add_point(point)

func get_last_point(offset: int = 0) -> Vector2:
	return points[points.size() - 1 - offset]


func add_collision_segment(index_1: int, index_2: int) -> void:
	var index_a: int = mini(index_1, index_2)
	var index_b: int = maxi(index_1, index_2)

	var collision_shape := CollisionShape2D.new()
	collision_shape.set_meta("point_index", index_a)

	var segment_shape := SegmentShape2D.new()
	segment_shape.a = points[index_a]
	segment_shape.b = points[index_b]
	collision_shape.shape = segment_shape
	collision_segment_count += 1
	call_deferred("add_child", collision_shape)


func release() -> void:
	await get_tree().create_timer(0.1).timeout
	for point_index in range(collision_segment_count, points.size() - 1):
		add_collision_segment(point_index, point_index + 1)


func split_at_segment(point_index: int, intersection_position: Vector2) -> Array[Edge]:
	var edge_1_points := points.slice(0, point_index+1)
	var edge_2_points := points.slice(point_index+1, points.size())
	edge_1_points.append(intersection_position)
	edge_2_points.insert(0, intersection_position)

	# print(point_index)
	# print("segment 1:", edge_1_points)
	# print("segment 2:", edge_2_points)

	var edge_1: Edge = EDGE.instantiate()
	edge_1.points = edge_1_points
	add_sibling(edge_1)
	edge_1.release()

	var edge_2: Edge = EDGE.instantiate()
	edge_2.points = edge_2_points
	add_sibling(edge_2)
	edge_2.release()

	# im worried that edges overlap when split on the same segment?

	queue_free()
	return [edge_1, edge_2]


class HalfEdge:
	var next: HalfEdge
	var prev: HalfEdge
	var twin: HalfEdge