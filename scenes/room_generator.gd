extends Node2D

@export var output_parent: Node2D


func _ready() -> void:
	hide()
	
	for spawner in get_children():
		if not spawner.has_method("get_spawn"):
			continue
		var spawn: Node2D = spawner.get_spawn()
		# also account for spawn that need a specific parent for z indexing, like hooks have their own parent and killareas have their own parent.
		output_parent.add_child(spawn)
