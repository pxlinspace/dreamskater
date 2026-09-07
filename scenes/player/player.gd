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

var speed: float = 0
var forward_direction: Vector2 = Vector2.RIGHT
var orbit_angle: float
var orbit_distance: float
var orbit_direction: int = 1

var state := State.IDLE
var hook: Hook
var is_magnet_hook_released_early: bool = false
var magnet_hold_time: float = 0.0

@onready var hook_detector: Node2D = $HookDetector


func _ready() -> void:
	Global.player = self
	SignalBus.player_ready.emit()


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("tap"):
		if state == State.IDLE:
			state = State.DEFAULT
			speed = INITIAL_DEFAULT_SPEED
			return
		
		if state == State.DEFAULT:
			hook = hook_detector.get_closest_hook()
			if not hook:
				return
			state = State.HOOKED
			hooked.emit()
			match hook.get_type():
				Hook.Type.ORBIT:
					speed = INITIAL_ORBIT_SPEED
					var relative_position: Vector2 = (global_position - hook.global_position)
					orbit_direction = -1 if relative_position.angle_to(forward_direction) < 0 else 1
					orbit_distance = relative_position.length()
					orbit_angle = relative_position.angle()
				Hook.Type.MAGNET:
					speed = INITIAL_MAGNET_SPEED
					forward_direction = (hook.global_position - global_position).normalized()
					hook.set_is_death(false)
			return
	
	
	elif event.is_action_released("tap"):
		if state == State.HOOKED:
			match hook.get_type():
				Hook.Type.ORBIT:
					speed += RELEASE_ORBIT_ACCEL
					unhook()
				Hook.Type.MAGNET:
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
		var hook_type := hook.get_type()
		if hook_type == Hook.Type.ORBIT:
			speed = move_toward(speed, MAX_ORBIT_SPEED, ORBIT_ACCEL * delta)
			orbit_angle += speed / orbit_distance * orbit_direction * delta
			var offset_position := Vector2(cos(orbit_angle), sin(orbit_angle)) * orbit_distance
			position = hook.global_position + offset_position
			forward_direction = offset_position.rotated(PI/2 * orbit_direction).normalized()

		elif hook_type == Hook.Type.MAGNET:
			speed = move_toward(speed, MAX_MAGNET_SPEED, MAGNET_ACCEL * delta)
			position = position.move_toward(hook.global_position, speed * delta)

			if position == hook.global_position:
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
