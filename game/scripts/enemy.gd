class_name Enemy
extends CharacterBody3D

const HIT_SOUND := preload("res://assets/audio/Impacto_Enemigo.mp3")
const DESTROY_SOUND := preload("res://assets/audio/Destruccion_Robot.mp3")

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
	
	var sound_position := _position
	if sound_position == Vector3.ZERO:
		sound_position = global_position
	_spawn_sound(HIT_SOUND, sound_position)
	
	if _health > 0:
		return
	
	_spawn_sound(DESTROY_SOUND, global_position)
	queue_free()


func _on_body_entered(body: Node3D) -> void:
	if not body.is_in_group("player"):
		return
	_player_ref = body


func _spawn_sound(stream: AudioStream, position: Vector3) -> void:
	var player := AudioStreamPlayer3D.new()
	player.stream = stream
	player.bus = "SFX"
	player.global_position = position
	player.finished.connect(player.queue_free)
	get_tree().current_scene.add_child(player)
	player.play()

func _on_body_exited(body: Node3D) -> void:
	if body != _player_ref:
		return
	_player_ref = null
