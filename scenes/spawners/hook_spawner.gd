extends Marker2D

const ORBIT_HOOK = preload("uid://sshx66tdsbck")
const MAGNET_HOOK = preload("uid://c1pkkc362d6mh")


@export var hook_type: Hook.Type


func get_spawn() -> Node2D:
	var hook: Node2D
	match hook_type:
		Hook.Type.ORBIT:
			hook = ORBIT_HOOK.instantiate()
		Hook.Type.MAGNET:
			hook = MAGNET_HOOK.instantiate()

	hook.position = global_position
	return hook