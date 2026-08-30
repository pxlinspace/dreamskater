class_name Player extends Node2D

signal hooked
signal unhooked

enum State {
	IDLE,
	DEFAULT,
	HOOKED,
}

const INITIAL_DEFAULT_SPEED: float = 200.0
const BASE_DEFAULT_SPEED: float = 100.0
const DEFAULT_ACCEL: float = 100.0
const INITIAL_ORBIT_SPEED: float = 35.0
const MAX_ORBIT_SPEED: float = 125.0
const RELEASE_ORBIT_ACCEL: float = 50.0
const ORBIT_ACCEL: float = 140.0
const INITIAL_MAGNET_SPEED: float = 15.0
const MAX_MAGNET_SPEED: float = 300.0
const MAGNET_ACCEL: float = 800.0
const RELEASE_MAGNET_SPEED: float = 300.0
const MAGNET_HOLD_WAIT_TIME: float = 0.1

const MAX_HOOK_DISTANCE_SQUARED: float = 15000

var speed: float = 0
var forward_direction: Vector2 = Vector2.RIGHT
var orbit_angle: float
var orbit_distance: float
var orbit_direction: int = 1

var state := State.IDLE
var hook_type: HookComponent.HookType
var hook_position: Vector2
var is_magnet_hook_released_early: bool = false
var magnet_hold_time: float = 0.0

@onready var hook_detector: Node2D = $HookDetector

func _ready() -> void:
	hook_detector.max_hook_distance_squared = MAX_HOOK_DISTANCE_SQUARED


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("tap"):
		if state == State.IDLE:
			state = State.DEFAULT
			speed = INITIAL_DEFAULT_SPEED
			return
		
		if state == State.DEFAULT:
			var closest_hook: HookComponent = hook_detector.get_closest_hook()
			if not closest_hook:
				return
			state = State.HOOKED
			hooked.emit()
			hook_type = closest_hook.type
			hook_position = closest_hook.global_position
			match hook_type:
				HookComponent.HookType.ORBIT:
					speed = INITIAL_ORBIT_SPEED
					var relative_position: Vector2 = (global_position - hook_position)
					orbit_direction = -1 if relative_position.angle_to(forward_direction) < 0 else 1
					orbit_distance = relative_position.length()
					orbit_angle = relative_position.angle()
				HookComponent.HookType.MAGNET:
					speed = INITIAL_MAGNET_SPEED
					forward_direction = (hook_position - global_position).normalized()
			return
	
	
	elif event.is_action_released("tap"):
		if state == State.HOOKED:
			match hook_type:
				HookComponent.HookType.ORBIT:
					speed += RELEASE_ORBIT_ACCEL
					unhook()
				HookComponent.HookType.MAGNET:
					if magnet_hold_time > 0:
						magnet_hold_time = 0
						unhook()
						speed = RELEASE_MAGNET_SPEED
						forward_direction = -forward_direction
					else:
						is_magnet_hook_released_early = true


func _physics_process(delta: float) -> void:
	if state == State.DEFAULT:
		speed = move_toward(speed, BASE_DEFAULT_SPEED, DEFAULT_ACCEL * delta)
		position += forward_direction * speed * delta

	elif state == State.HOOKED:
		if hook_type == HookComponent.HookType.ORBIT:
			speed = move_toward(speed, MAX_ORBIT_SPEED, ORBIT_ACCEL * delta)
			orbit_angle += speed / orbit_distance * orbit_direction * delta
			var offset_position := Vector2(cos(orbit_angle), sin(orbit_angle)) * orbit_distance
			position = hook_position + offset_position
			forward_direction = offset_position.rotated(PI/2 * orbit_direction).normalized()

		elif hook_type == HookComponent.HookType.MAGNET:
			speed = move_toward(speed, MAX_MAGNET_SPEED, MAGNET_ACCEL * delta)
			position = position.move_toward(hook_position, speed * delta)

			if position == hook_position:
				if is_magnet_hook_released_early:
					is_magnet_hook_released_early = false
					unhook()
					speed = RELEASE_MAGNET_SPEED
					forward_direction = -forward_direction
				else:
					magnet_hold_time += delta
					if magnet_hold_time < MAGNET_HOLD_WAIT_TIME:
						speed = 0.0
					else:
						magnet_hold_time = 0
						unhook()
						speed = RELEASE_MAGNET_SPEED


func _on_hitbox_area_entered(_area: Area2D) -> void:
	get_tree().call_deferred("reload_current_scene")


func unhook() -> void:
	unhooked.emit()
	state = State.DEFAULT