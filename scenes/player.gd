class_name Player extends CharacterBody2D

signal started_hook

enum State {
	IDLE,
	DEFAULT,
	HOOKED,
}

const MAX_HOOK_DISTANCE_SQUARED: float = 22500

const INITIAL_DEFAULT_SPEED: float = 150.0
const BASE_DEFAULT_SPEED: float = 125.0
const DEFAULT_ACCEL: float = 100.0
const INITIAL_ORBIT_SPEED: float = 35.0
const MAX_ORBIT_SPEED: float = 125.0
const RELEASE_ORBIT_ACCEL: float = 50.0
const ORBIT_ACCEL: float = 140.0

var direction: Vector2 = Vector2.RIGHT
var speed: float = 0

var state := State.IDLE
var hook_type: Hook.HookType
var hook_position: Vector2


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("tap"):
		if state == State.IDLE:
			state = State.DEFAULT
			speed = INITIAL_DEFAULT_SPEED
			return
		
		if state == State.DEFAULT:
			var closest_hook := get_closest_hook()
			if not closest_hook:
				return
			state = State.HOOKED
			started_hook.emit()
			hook_type = closest_hook.type
			hook_position = closest_hook.global_position
			match hook_type:
				Hook.HookType.ORBIT:
					speed = INITIAL_ORBIT_SPEED
			return
	
	
	elif event.is_action_released("tap"):
		if state == State.HOOKED:
			state = State.DEFAULT
			speed += RELEASE_ORBIT_ACCEL


func _physics_process(delta: float) -> void:
	move_and_slide()

	if state == State.DEFAULT:
		speed = move_toward(speed, BASE_DEFAULT_SPEED, DEFAULT_ACCEL * delta)
	elif state == State.HOOKED:
		speed = move_toward(speed, MAX_ORBIT_SPEED, ORBIT_ACCEL * delta)
		match hook_type:
			Hook.HookType.ORBIT:
				var direction_to_hook: Vector2 = (hook_position - global_position).normalized()
				var is_rotating_clockwise: bool = direction_to_hook.angle_to(direction) < 0
				direction = direction_to_hook.rotated(PI/2 * (-1 if is_rotating_clockwise else 1)) # THIS MATH IS NOT PRECISE AND WILL LOSE ACCURACY OVER TIME

	velocity = speed * direction


func _on_hitbox_area_entered(_area: Area2D) -> void:
	get_tree().reload_current_scene() # temp code cuz scene reloading will be managed externally


func get_closest_hook() -> Hook:
	var closest_hook: Hook
	var closest_hook_distance_squared: float = INF
	for hook: Hook in get_tree().get_nodes_in_group("hooks"):
		var hook_distance_squared := global_position.distance_squared_to(hook.global_position)
		if hook_distance_squared < closest_hook_distance_squared:
			closest_hook_distance_squared = hook_distance_squared
			closest_hook = hook
	return closest_hook
