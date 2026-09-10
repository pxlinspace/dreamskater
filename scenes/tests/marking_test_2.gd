extends Node2D

const MARKING: PackedScene = preload("uid://dd0c3y8d3jqy5")

var intersections: Array[Intersection] = []
var polygons: Array[PackedVector2Array] = []
var is_holding := false

@onready var marking_container: Node2D = $MarkingContainer
@onready var mouse_area: Area2D = $MouseArea
@onready var mouse_area_segment_shape: SegmentShape2D = $MouseArea/CollisionShape2D.shape


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("tap"):
		is_holding = true
		var marking: Marking = MARKING.instantiate()
		marking.add_point(get_local_mouse_position())
		marking.add_point(get_local_mouse_position())
		marking_container.add_child(marking)

		mouse_area_segment_shape.b = get_local_mouse_position()
		mouse_area_segment_shape.a = get_local_mouse_position()
	
	elif event.is_action_released("tap"):
		is_holding = false
		marking_container.get_child(-1).release()


func _physics_process(_delta: float) -> void:
	if is_holding:
		queue_redraw()
		mouse_area_segment_shape.b = mouse_area_segment_shape.a
		mouse_area_segment_shape.a = get_local_mouse_position()
		marking_container.get_child(-1).set_last_point(get_local_mouse_position())


func _draw() -> void:
	for marking: Marking in marking_container.get_children():
		if marking.points.size() > 1:
			if marking.highlighted:
				draw_polyline(marking.points, Color.LIGHT_BLUE, 4)
			else:
				draw_polyline(marking.points, Color.WHITE, 2)
		for point in marking.points:
			draw_circle(point, 3, Color.WHITE)
	
	for intersection in intersections:
		if intersection.highlighted:
			draw_circle(intersection.position, 4, Color.BLUE)
		else:
			draw_circle(intersection.position, 2, intersection.color)
	
	for polygon in polygons:
		draw_colored_polygon(polygon, Color(Color.RED, 0.5))
	
	draw_line(mouse_area_segment_shape.a, mouse_area_segment_shape.b, Color.GREEN, 3)


func _on_mouse_area_area_shape_entered(
		_area_rid: RID, other_marking: Marking, other_marking_shape_index: int, _local_shape_index: int
) -> void:
	if not is_holding:
		return
	var player_marking: Marking = marking_container.get_child(-1)

	var other_marking_shape_owner: int = other_marking.shape_find_owner(other_marking_shape_index)
	var other_marking_collision_shape: CollisionShape2D = other_marking.shape_owner_get_owner(other_marking_shape_owner)
	var other_marking_segment_shape: SegmentShape2D = other_marking_collision_shape.shape

	var intersection_position: Variant = Geometry2D.segment_intersects_segment(
			other_marking_segment_shape.a, other_marking_segment_shape.b,
			mouse_area_segment_shape.a, mouse_area_segment_shape.b
	) # there is a bug where sometimes this value returns nil instead of vector2. ill fix this later
	if intersection_position == null:
		return
	
	# player_marking.add_point(intersection_position)

	var intersection := Intersection.new()
	intersection.position = intersection_position
	intersection.marking_indices = [player_marking.get_index(), other_marking.get_index()]

	intersections.append(intersection)
	var intersection_index := intersections.size()-1

	player_marking.add_intersection(intersection_index, player_marking.points.size()-2)
	var point_index: int = other_marking_collision_shape.get_meta("point_index")
	other_marking.add_intersection(intersection_index, point_index)
	# other_marking.add_intersection(intersection_index, other_marking_collision_shape.get_meta("point_index"))

	print(is_closed_shape(intersection_index, other_marking), "\n------------------\n\n")


func is_closed_shape(root_intersection_index: int, starting_marking: Marking) -> Variant:
	var starting_marking_index := starting_marking.get_index()

	var marking_indices_found: PackedInt32Array = [starting_marking_index]
	var intersection_indices_found: PackedInt32Array = []

	var marking_index_sequence: PackedInt32Array = []
	var intersection_index_sequence: PackedInt32Array = []


	var success: bool = search_complete_shape_sequence(
			marking_index_sequence, intersection_index_sequence,
			root_intersection_index, starting_marking, marking_indices_found, intersection_indices_found, true
	)

	# print(marking_index_sequence)
	# print(intersection_index_sequence)

	for i in intersection_index_sequence:
		intersections[i].highlighted = true
	for i in marking_index_sequence:
		marking_container.get_child(i).highlighted = true
	
	if success:
		polygons.append(get_polygon_from_sequence(marking_index_sequence, intersection_index_sequence))
	
	return "bruh"


func get_polygon_from_sequence(
		marking_index_sequence: PackedInt32Array, intersection_index_sequence: PackedInt32Array
) -> PackedVector2Array:
	var polygon: PackedVector2Array = []
	var size := intersection_index_sequence.size()

	for i in size:
		var intersection_index := intersection_index_sequence[i]
		var next_intersection_index := intersection_index_sequence[(i+1) % size]

		var intersection_position := intersections[intersection_index].position
		polygon.append(intersection_position)
		print("intersection position, ", intersection_index, " : ", intersection_position)

		var marking: Marking = marking_container.get_child(marking_index_sequence[i])
		var marking_points: PackedVector2Array = marking.points
		var starting_point_index := marking.point_indices_intersected[marking.intersection_indices.find(intersection_index)]
		var ending_point_index := marking.point_indices_intersected[marking.intersection_indices.find(next_intersection_index)]

		if starting_point_index == ending_point_index:
			continue

		print("Checking marking index: ", marking_index_sequence[i])
		print("STARTING POINT INDEX: ", starting_point_index)
		print("ENDING POINT INDEX: ", ending_point_index)
		
		if starting_point_index < ending_point_index:
			starting_point_index += 1
			for point_index in range(starting_point_index, ending_point_index+1):
				polygon.append(marking_points[point_index])
				print("marking point position, ", point_index, marking_points[point_index])
		elif starting_point_index > ending_point_index:
			ending_point_index += 1
			for point_index in range(starting_point_index, ending_point_index-1, -1):
				polygon.append(marking_points[point_index])
				print("marking point position, ", point_index, marking_points[point_index])

		print("Checking marking index after update: ", marking_index_sequence[i])
		print("STARTING POINT INDEX: ", starting_point_index)
		print("ENDING POINT INDEX: ", ending_point_index)
	
	print(polygon)
	return polygon


func search_complete_shape_sequence(
		marking_index_sequence: PackedInt32Array,
		intersection_index_sequence: PackedInt32Array,
		root_intersection_index: int,
		current_marking: Marking,
		marking_indices_found: PackedInt32Array,
		intersection_indices_found: PackedInt32Array,
		just_started: bool = false
) -> bool:
	var current_marking_index := current_marking.get_index()
	var intersection_indices_to_search: PackedInt32Array = []

	for intersection_index in current_marking.intersection_indices:
		if intersection_index == root_intersection_index:
			if just_started:
				continue
			intersection_index_sequence.append(intersection_index)
			marking_index_sequence.append(current_marking_index)
			return true
		
		if intersection_indices_found.has(intersection_index):
			continue
		
		intersection_indices_found.append(intersection_index)
		intersection_indices_to_search.append(intersection_index)

	for intersection_index in intersection_indices_to_search:
		for other_marking_index in intersections[intersection_index].marking_indices:
			if marking_indices_found.has(other_marking_index):
				continue
			var other_marking: Marking = marking_container.get_child(other_marking_index)
			marking_indices_found.append(other_marking_index)
			
			var success: Variant = search_complete_shape_sequence(
					marking_index_sequence, intersection_index_sequence,
					root_intersection_index, other_marking, marking_indices_found, intersection_indices_found
			)

			if success:
				intersection_index_sequence.append(intersection_index)
				marking_index_sequence.append(current_marking_index)
				return true

	return false


class Intersection:
	var position: Vector2
	var marking_indices: PackedInt32Array
	var color: = Color(randf(), randf(), randf()) # temp property for testing
	var highlighted: bool = false # temp property for testing
	var ultrahighlighted: bool = false


# next steps:
# okay, polygon creation works! The only problem is that sometimes it doesn't work lol, like there's no apparent pattern its just random. 
