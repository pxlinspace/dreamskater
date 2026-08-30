class_name Player extends Node2D

signal hooked
signal unhooked

enum State {
	IDLE,
	DEFAULT,
	HOOKED,
}

const INITIAL_DEFAULT_SPEED: float = 130.0
const BASE_DEFAULT_SPEED: float = 100.0
const DEFAULT_ACCEL: float = 100.0
const INITIAL_ORBIT_SPEED: float = 35.0
const MAX_ORBIT_SPEED: float = 125.0
const RELEASE_ORBIT_ACCEL: float = 50.0
const ORBIT_ACCEL: float = 140.0
const INITIAL_MAGNET_SPEED: float = 15.0
const MAX_MAGNET_SPEED: float = 250.0
const MAGNET_ACCEL: float = 800.0
const RELEASE_MAGNET_SPEED: float = 300.0

const MAX_HOOK_DISTANCE_SQUARED: float = 15000
# const MAX_MAGNET_RELEASE_DISTANCE_SQUARED: float = 400.0

var speed: float = 0
var forward_direction: Vector2 = Vector2.RIGHT
var orbit_angle: float
var orbit_distance: float
var orbit_direction: int = 1

var state := State.IDLE
var hook_type: Hook.HookType
var hook_position: Vector2
var is_magnet_hook_released_early: bool = false


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
			hooked.emit()
			hook_type = closest_hook.type
			hook_position = closest_hook.global_position
			match hook_type:
				Hook.HookType.ORBIT:
					speed = INITIAL_ORBIT_SPEED
					var relative_position: Vector2 = (global_position - hook_position)
					orbit_direction = -1 if relative_position.angle_to(forward_direction) < 0 else 1
					orbit_distance = relative_position.length()
					orbit_angle = relative_position.angle()
				Hook.HookType.MAGNET:
					speed = INITIAL_MAGNET_SPEED
					forward_direction = (hook_position - global_position).normalized()
			return
	
	
	elif event.is_action_released("tap"):
		if state == State.HOOKED:
			match hook_type:
				Hook.HookType.ORBIT:
					speed += RELEASE_ORBIT_ACCEL
					unhooked.emit()
					state = State.DEFAULT
				Hook.HookType.MAGNET:
					is_magnet_hook_released_early = true
					# if global_position.distance_squared_to(hook_position) <= MAX_MAGNET_RELEASE_DISTANCE_SQUARED:
					# 	forward_direction = -forward_direction


func _physics_process(delta: float) -> void:
	if state == State.DEFAULT:
		speed = move_toward(speed, BASE_DEFAULT_SPEED, DEFAULT_ACCEL * delta)
		position += forward_direction * speed * delta

	elif state == State.HOOKED:
		match hook_type:
			Hook.HookType.ORBIT:
				speed = move_toward(speed, MAX_ORBIT_SPEED, ORBIT_ACCEL * delta)
				orbit_angle += speed / orbit_distance * orbit_direction * delta
				var offset_position := Vector2(cos(orbit_angle), sin(orbit_angle)) * orbit_distance
				position = hook_position + offset_position
				forward_direction = offset_position.rotated(PI/2 * orbit_direction).normalized()
			Hook.HookType.MAGNET:
				speed = move_toward(speed, MAX_MAGNET_SPEED, MAGNET_ACCEL * delta)
				position = position.move_toward(hook_position, speed * delta)
				if position == hook_position:
					unhooked.emit()
					state = State.DEFAULT
					speed = RELEASE_MAGNET_SPEED
					if is_magnet_hook_released_early:
						is_magnet_hook_released_early = false
						forward_direction = -forward_direction


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
