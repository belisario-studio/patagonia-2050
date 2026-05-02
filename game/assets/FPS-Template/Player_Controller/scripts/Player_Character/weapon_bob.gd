extends Node3D

@export var bob_frequency: float = 2
@export var bob_amplitude: float = 0.06
@export var sprint_multiplier: float = 1.3
@export var landing_offset: float = 0.08
@export var smooth_speed: float = 10.0

var _base_position: Vector3
var _base_rotation: Vector3
var _bob_time: float = 0.0
var _was_on_floor: bool = true
var _target_position: Vector3
var _target_rotation: Vector3
var _player: CharacterBody3D


func _ready() -> void:
	_base_position = position
	_base_rotation = rotation
	_target_position = _base_position
	_target_rotation = _base_rotation
	_player = _find_player()


func _find_player() -> CharacterBody3D:
	var node := get_parent()
	while node != null:
		if node is CharacterBody3D:
			return node
		node = node.get_parent()
	return null


func _process(delta: float) -> void:
	if _player == null:
		return

	var horizontal_speed := Vector2(_player.velocity.x, _player.velocity.z).length()
	var is_on_floor := _player.is_on_floor()

	_update_bob_time(delta, horizontal_speed, is_on_floor)
	_calculate_target_transform(horizontal_speed, is_on_floor)
	_apply_smooth_transform(delta)

	_was_on_floor = is_on_floor


func _update_bob_time(delta: float, horizontal_speed: float, is_on_floor: bool) -> void:
	if not is_on_floor:
		return
	if horizontal_speed < 0.1:
		return
	var speed_mult := _get_speed_multiplier()
	_bob_time += delta * horizontal_speed * bob_frequency * speed_mult


func _get_speed_multiplier() -> float:
	if _player.speed_modifier >= _player.sprint_speed - 0.1:
		return sprint_multiplier
	return 1.0


func _calculate_target_transform(horizontal_speed: float, is_on_floor: bool) -> void:
	_target_position = _base_position
	_target_rotation = _base_rotation

	if is_on_floor:
		_apply_running_bob(horizontal_speed)
		_apply_landing_bump()
		return

	_apply_air_sway()


func _apply_running_bob(horizontal_speed: float) -> void:
	if horizontal_speed < 0.1:
		return
	var y_bob := sin(_bob_time) * bob_amplitude
	var x_bob := cos(_bob_time * 0.5) * bob_amplitude * 0.3
	var speed_mult := _get_speed_multiplier()
	_target_position.y += y_bob * speed_mult
	_target_position.x += x_bob * speed_mult


func _apply_landing_bump() -> void:
	if _was_on_floor:
		return
	_target_position.y += landing_offset


func _apply_air_sway() -> void:
	var vertical_velocity := _player.velocity.y
	_target_position.y += vertical_velocity * 0.01
	_target_rotation.x += vertical_velocity * 0.02


func _apply_smooth_transform(delta: float) -> void:
	position = position.lerp(_target_position, smooth_speed * delta)
	rotation = rotation.lerp(_target_rotation, smooth_speed * delta)
