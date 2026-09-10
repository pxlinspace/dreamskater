extends Node2D

const EDGE: PackedScene = preload("uid://cqqqfea8cod36")

var is_holding := false
var last_mouse_position: Vector2

var intersections: PackedVector2Array # temp for testing

@onready var edge_container: Node2D = $EdgeContainer
@onready var detector: RayCast2D = $Detector

var bruh: int = 0


func _draw() -> void:
	for edge: Edge in edge_container.get_children():
		for i in edge.points.size()-1:
			var point := edge.points[i]
			var next_point := edge.points[i+1]
			draw_line(point, next_point, edge.color, 2)
			var offset: Vector2 = (point - next_point).normalized().rotated(PI * 0.2) * 6
			draw_line(point - offset, point + offset, Color.WHITE, 1)
			draw_circle(point, 2, Color.WHITE)
		draw_circle(edge.points[edge.points.size()-1], 4, Color.RED)
	
	for pos in intersections:
		draw_circle(pos, 5, Color.BLUE)


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("tap"):
		is_holding = true
		create_player_edge()
		last_mouse_position = get_local_mouse_position()
		detector.position = get_local_mouse_position()
		detector.target_position = Vector2.ZERO
		detector.set_deferred("enabled", true)

	
	elif event.is_action_released("tap"):
		is_holding = false
		get_player_edge().release()
		detector.enabled = false


func _physics_process(_delta: float) -> void:
	if is_holding:
		queue_redraw()
		var mouse_position := get_local_mouse_position()
		detector.position = last_mouse_position
		detector.target_position = (mouse_position - last_mouse_position)
		last_mouse_position = mouse_position

		if detector.target_position.length_squared() > 1600:
			detector.target_position = detector.target_position.normalized() * 40

		var player_edge := get_player_edge()
		player_edge.set_last_point(get_local_mouse_position())

		if detector.is_colliding():
			
			var edge: Edge = detector.get_collider() # A CollisionObject2D.
			var shape_id := detector.get_collider_shape() # The shape index in the collider.
			var owner_id := edge.shape_find_owner(shape_id) # The owner ID in the collider.
			var collision_shape: CollisionShape2D = edge.shape_owner_get_owner(owner_id)
			var segment_shape: SegmentShape2D = collision_shape.shape
			

			var intersection_position := detector.get_collision_point()

			get_player_edge().set_last_point(intersection_position)
			player_edge.release()

			create_player_edge(intersection_position)

			
			print(bruh, ": ", intersection_position)
			bruh += 1
			intersections.append(intersection_position)


func create_player_edge(new_position: Vector2 = get_local_mouse_position()) -> void:
	var edge: Edge = EDGE.instantiate()
	edge.add_point(new_position)
	edge.add_point(new_position)

	edge_container.add_child(edge)


func get_player_edge() -> Edge:
	return edge_container.get_child(-1)


# next steps: 
# fix stray intersections that are created whenever the mouse moves quickly on the first intersection