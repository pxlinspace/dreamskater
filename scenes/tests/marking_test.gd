extends Node2D

const MAX_POINT_DISTANCE_SQUARED = 3000.0

var points: Array[Point]


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("tap"):
		create_point()
		queue_redraw()


func _draw() -> void:
	for point in points:
		draw_circle(point.position, 4, Color.WHITE)
		for i in point.linked_indices:
			var arrow_point_1 := point.position.move_toward(points[i].position, 8.0)
			var arrow_point_2 := points[i].position.move_toward(point.position, 8.0)
			var arrow_point_3 := arrow_point_2 - (arrow_point_2 - arrow_point_1).normalized().rotated(PI*0.15) * 8
			var arrow_point_4 := arrow_point_2 - (arrow_point_2 - arrow_point_1).normalized().rotated(-PI*0.15) * 8

			draw_line(arrow_point_1, arrow_point_2, Color.GRAY)
			draw_line(arrow_point_2, arrow_point_3, Color.GRAY)
			draw_line(arrow_point_2, arrow_point_4, Color.GRAY)


func create_point() -> void:
	var point := Point.new()
	point.position = get_local_mouse_position()
	points.append(point)

	update_linked_indices()
	check_closed_shapes()


func update_linked_indices() -> void:
	for i in points.size():
		for j in points.size():
			var p1 := points[i].position
			var p2 := points[j].position
			if p1.distance_squared_to(p2) < MAX_POINT_DISTANCE_SQUARED and p2.x > p1.x:
				points[i].linked_indices.append(j)


func check_closed_shapes() -> void:
	for point in points:
		if point.linked_indices.size() < 2:
			continue


class Point:
	var position: Vector2
	var linked_indices: PackedInt32Array