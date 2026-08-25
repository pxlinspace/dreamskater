extends CharacterBody2D

enum State {
	IDLE,
	DEFAULT,
	HOOKED,
}

const MAX_HOOK_DISTANCE_SQUARED: float = 22500
const DEFAULT_SPEED: float = 90.0

var direction: Vector2 = Vector2.RIGHT
var speed: float = 0

var state := State.IDLE
var hook_type: Hook.HookType
var hook_position: Vector2


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("tap"):
		if state == State.IDLE:
			start()
			return
		
		if state == State.DEFAULT:
			var closest_hook := get_closest_hook()
			if closest_hook:
				state = State.HOOKED
				hook_type = closest_hook.type
				hook_position = closest_hook.global_position
			return
	
	elif event.is_action_released("tap"):
		if state == State.HOOKED:
			state = State.DEFAULT


func _physics_process(_delta: float) -> void:
	if state == State.DEFAULT:
		speed = DEFAULT_SPEED # temp code cuz speed will be variable
	elif state == State.HOOKED:
		match hook_type:
			Hook.HookType.ORBIT:
				var direction_to_hook: Vector2 = (hook_position - global_position).normalized()
				var is_rotating_clockwise: bool = direction_to_hook.angle_to(direction) < 0
				direction = direction_to_hook.rotated(PI/2 * (-1 if is_rotating_clockwise else 1))

	velocity = speed * direction
	move_and_slide()


func _on_hitbox_area_entered(_area: Area2D) -> void:
	get_tree().reload_current_scene() # temp code cuz scene reloading will be managed externally


func start() -> void:
	state = State.DEFAULT
	speed = DEFAULT_SPEED


func get_closest_hook() -> Hook:
	var closest_hook: Hook
	var closest_hook_distance_squared: float = INF
	for hook: Hook in get_tree().get_nodes_in_group("hooks"):
		var hook_distance_squared := global_position.distance_squared_to(hook.global_position)
		if hook_distance_squared < closest_hook_distance_squared:
			closest_hook_distance_squared = hook_distance_squared
			closest_hook = hook
	return closest_hook
