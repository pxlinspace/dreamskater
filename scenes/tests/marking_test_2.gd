extends Node2D

const MARKING: PackedScene = preload("uid://dd0c3y8d3jqy5")

var is_holding := false
@onready var marking_container: Node2D = $MarkingContainer
@onready var mouse_area: Area2D = $MouseArea


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
	if is_holding:
		queue_redraw()
		mouse_area.position = get_local_mouse_position()
		marking_container.get_child(-1).set_last_point(get_local_mouse_position())


func _draw() -> void:
	for marking: Marking in marking_container.get_children():
		if marking.points.size() > 1:
			draw_polyline(marking.points, Color.WHITE, 2)


func _on_mouse_area_area_entered(intersected_marking: Marking) -> void:
	if not is_holding:
		return
	var player_marking: Marking = marking_container.get_child(-1)
	player_marking.add_intersected_marking(intersected_marking.get_index())
	intersected_marking.add_intersected_marking(player_marking.get_index())
	print(is_closed_shape(player_marking))


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


# next steps:
# tracking down the sequence of indices that form the closed shape
# FUUCKKK since 2 markings can form multiple closed shapes, I'm gonna have to find a way to track down the positions of each intersection too.
# fuuuuucccccckkkkkkk