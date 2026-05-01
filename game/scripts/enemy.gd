class_name Enemy
extends CharacterBody3D

@export var max_health: int = 100
@export var move_speed: float = 3.0

var _health: int
var _player_ref: Node3D

@onready var _detection_zone: Area3D = $DetectionZone


func _ready() -> void:
	_health = max_health
	_detection_zone.body_entered.connect(_on_body_entered)
	_detection_zone.body_exited.connect(_on_body_exited)


func _physics_process(_delta: float) -> void:
	if _player_ref == null:
		return

	var direction := _player_ref.global_position - global_position
	direction.y = 0.0

	if direction.length_squared() < 0.01:
		return

	direction = direction.normalized()
	velocity = direction * move_speed
	move_and_slide()


func Hit_Successful(damage: int, _direction: Vector3 = Vector3.ZERO, _position: Vector3 = Vector3.ZERO) -> void:
	_health -= damage
	if _health > 0:
		return
	queue_free()


func _on_body_entered(body: Node3D) -> void:
	if not body.is_in_group("player"):
		return
	_player_ref = body


func _on_body_exited(body: Node3D) -> void:
	if body != _player_ref:
		return
	_player_ref = null
