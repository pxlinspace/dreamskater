extends Node2D

# clip (difference) - SubtractionShape
# merge (union) - 


@onready var polygon_1: Polygon2D = $Polygon1
@onready var polygon_2: Polygon2D = $Polygon1/Polygon2


var union: Array[PackedVector2Array]
var convex_hulls: Array[PackedVector2Array]

func _ready() -> void:
	union = Geometry2D.merge_polygons(polygon_1.polygon, polygon_2.polygon)
	convex_hulls = Geometry2D.decompose_polygon_in_convex(union[0])
	
	print(union)

func _draw() -> void:
	# draw_colored_polygon(union[0], Color.WHITE)
	# draw_colored_polygon(union[1], Color.RED)
	for convex_hull in convex_hulls:
		draw_colored_polygon(convex_hull, Color(randf(), randf(), randf()))
