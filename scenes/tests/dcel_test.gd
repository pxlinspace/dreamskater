extends Node2D

const EDGE: PackedScene = preload("uid://cqqqfea8cod36")
const MAX_DETECTOR_LENGTH: float = 40.0
const MAX_DETECTOR_LENGTH_SQUARED: float = MAX_DETECTOR_LENGTH**2
const FAST_PLAYER_SPEED_SQUARED: float = 600.0

var is_holding := false
var last_mouse_position: Vector2

var intersections: PackedVector2Array # temp for testing

@onready var edge_container: Node2D = $EdgeContainer
@onready var detector: RayCast2D = $Detector


func _draw() -> void:
	for edge: Edge in edge_container.get_children():
		for i in edge.points.size()-1:
			var point := edge.points[i]
			var next_point := edge.points[i+1]
			draw_line(point, next_point, Color(edge.color, 0.5), 2)
			var offset: Vector2 = (point - next_point).normalized().rotated(PI * 0.2) * 6
			draw_line(point - offset, point + offset, Color.WHITE, 1)
			draw_circle(point, 2, Color.WHITE)
		draw_circle(edge.points[edge.points.size()-1], 4, Color.RED)
	
	# for pos in intersections:
	# 	draw_circle(pos, 5, Color.BLUE)


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("tap"):
		is_holding = true
		create_player_edge()

	
	elif event.is_action_released("tap"):
		is_holding = false
		release_player_edge()


func _physics_process(_delta: float) -> void:
	if not is_holding:
		return
	
	queue_redraw()
	var mouse_position := get_local_mouse_position()
	detector.position = last_mouse_position
	detector.target_position = (mouse_position - last_mouse_position)

	var is_player_moving_slowly := mouse_position.distance_squared_to(last_mouse_position) < FAST_PLAYER_SPEED_SQUARED
	last_mouse_position = mouse_position

	if detector.target_position.length_squared() > MAX_DETECTOR_LENGTH_SQUARED:
		detector.target_position = detector.target_position.normalized() * MAX_DETECTOR_LENGTH

	if detector.is_colliding():
		process_detector()
	
	get_player_edge().set_last_point(get_local_mouse_position(), is_player_moving_slowly)


func process_detector() -> void:
	var edge: Edge = detector.get_collider()
	var shape_id := detector.get_collider_shape()
	var owner_id := edge.shape_find_owner(shape_id)
	var collision_shape: CollisionShape2D = edge.shape_owner_get_owner(owner_id)

	var segment_shape: SegmentShape2D = collision_shape.shape
	var segment_vector: Vector2 = segment_shape.b - segment_shape.a
	var is_main_side_touched: bool = detector.target_position.angle_to(segment_vector) <= 0
	
	# print(is_main_side_touched)
	var intersection_position := detector.get_collision_point()
	intersections.append(intersection_position)

	var split_result: Array[Edge] = edge.split_at_segment(collision_shape.get_meta("point_index"), intersection_position)

	var edge_a: Edge = split_result[0]
	var edge_b: Edge = split_result[1]

	var old_main_prev := edge.main_half.prev
	var old_main_next := edge.main_half.next
	var old_twin_prev := edge.twin_half.prev
	var old_twin_next := edge.twin_half.next

	Edge.link_half_edges(old_main_prev, edge_a.main_half)
	Edge.link_half_edges(edge_b.main_half, old_main_next)

	Edge.link_half_edges(old_twin_prev, edge_b.twin_half)
	Edge.link_half_edges(edge_a.twin_half, old_twin_next)


	var edge_c: Edge = get_player_edge()

	edge_c.set_last_point(intersection_position, false)
	release_player_edge()
	create_player_edge(intersection_position)

	var edge_d: Edge = get_player_edge()

	print("-------------")

	if is_main_side_touched:
		Edge.link_half_edges(edge_c.main_half, edge_b.main_half)
		Edge.link_half_edges(edge_b.twin_half, edge_d.main_half)
		Edge.link_half_edges(edge_d.twin_half, edge_a.twin_half)
		Edge.link_half_edges(edge_a.main_half, edge_c.twin_half)

		print(find_polygon(edge_a.main_half))
		print(find_polygon(edge_c.main_half))
		print(find_polygon(edge_b.twin_half))
		print(find_polygon(edge_d.twin_half))
	else:
		Edge.link_half_edges(edge_c.main_half, edge_a.twin_half)
		Edge.link_half_edges(edge_a.main_half, edge_d.main_half)
		Edge.link_half_edges(edge_d.twin_half, edge_b.main_half)
		Edge.link_half_edges(edge_b.twin_half, edge_c.twin_half)

		print(find_polygon(edge_b.twin_half))
		print(find_polygon(edge_c.main_half))
		print(find_polygon(edge_a.main_half))
		print(find_polygon(edge_d.twin_half))


func find_polygon(start_half: Edge.HalfEdge) -> bool:
	var sequence: Array[Edge.HalfEdge] = []
	var current_half := start_half
	while is_instance_valid(current_half):
		sequence.append(current_half)
		current_half = current_half.next
		if current_half == start_half:
			print(sequence)
			return true
	return false


func create_player_edge(new_position: Vector2 = get_local_mouse_position()) -> void:
	var edge: Edge = EDGE.instantiate()
	edge.add_point(new_position)
	edge.add_point(new_position)

	edge_container.add_child(edge)

	last_mouse_position = get_local_mouse_position()
	detector.position = get_local_mouse_position()
	detector.target_position = Vector2.ZERO
	detector.set_deferred("enabled", true)


func release_player_edge() -> void:
	get_player_edge().release()
	detector.enabled = false


func get_player_edge() -> Edge:
	return edge_container.get_child(-1)


# next steps: 
# fix stray intersections that are created whenever the mouse moves quickly on the first intersection
