extends Node2D

const MARKING: PackedScene = preload("uid://dd0c3y8d3jqy5")

var intersections: Array[Intersection] = []
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
	
	elif event.is_action_released("tap"):
		is_holding = false
		marking_container.get_child(-1).release()


func _physics_process(_delta: float) -> void:
	print("number of intersections:", intersections.size())
	if is_holding:
		queue_redraw()
		mouse_area_segment_shape.b = mouse_area_segment_shape.a
		mouse_area_segment_shape.a = get_local_mouse_position()
		marking_container.get_child(-1).set_last_point(get_local_mouse_position())


func _draw() -> void:
	for marking: Marking in marking_container.get_children():
		if marking.points.size() > 1:
			draw_polyline(marking.points, Color.WHITE, 2)
	
	for intersection in intersections:
		draw_circle(intersection.position, 2, intersection.color)
	
	draw_line(mouse_area_segment_shape.a, mouse_area_segment_shape.b, Color.GREEN, 3)


func _on_mouse_area_area_shape_entered(_area_rid: RID, other_marking: Marking, other_marking_shape_index: int, _local_shape_index: int) -> void:
	if not is_holding:
		return
	var player_marking: Marking = marking_container.get_child(-1)

	var other_marking_shape_owner: int = other_marking.shape_find_owner(other_marking_shape_index)
	var other_marking_collision_shape: CollisionShape2D = other_marking.shape_owner_get_owner(other_marking_shape_owner)
	var other_marking_segment_shape: SegmentShape2D = other_marking_collision_shape.shape

	var intersection_position: Vector2 = Geometry2D.segment_intersects_segment(
			other_marking_segment_shape.a, other_marking_segment_shape.b,
			mouse_area_segment_shape.a, mouse_area_segment_shape.b
	)

	var intersection := Intersection.new()
	intersection.position = intersection_position
	intersection.marking_indices = [player_marking.get_index(), other_marking.get_index()]

	intersections.append(intersection)
	var intersection_index := intersections.size()-1

	player_marking.add_intersection(intersection_index)
	other_marking.add_intersection(intersection_index)

	player_marking.add_point(intersection_position)


func is_closed_shape(root_marking: Marking) -> bool:
	var root_index := root_marking.get_index()
	var target_index: int = root_marking.intersected_indices[0]
	var indices_found: PackedInt32Array = [root_index]
	
	return find_unique_indices(root_index, target_index, indices_found)


func find_unique_indices(root_index: int, target_index: int, indices_found: PackedInt32Array) -> bool:
	for intersected_index: int in marking_container.get_child(root_index).intersected_indices:
		if root_index == target_index:
			return false
		if indices_found.has(intersected_index):
			if intersected_index == target_index:
				return true
			else:
				continue
		indices_found.append(intersected_index)
		print("indices found: ", indices_found)
		if find_unique_indices(intersected_index, target_index, indices_found):
			return true
	return false


class Intersection:
	var position: Vector2
	var marking_indices: PackedInt32Array # an intersection will only ever have 2 markings
	var color: = Color(randf(), randf(), randf()) # temp property for testing


# next steps:
# tracking down the sequence of indices that form the closed shape
# FUUCKKK since 2 markings can form multiple closed shapes, I'm gonna have to find a way to track down the positions of each intersection too.
# fuuuuucccccckkkkkkk
