class_name Enemy
extends CharacterBody3D

const HIT_SOUND := preload("res://assets/audio/Impacto_Enemigo.mp3")
const DESTROY_SOUND := preload("res://assets/audio/Destruccion_Robot.mp3")

enum State { IDLE, CHASE, ATTACK, DEAD }

@export var max_health: int = 100
@export var move_speed: float = 3.0
@export var aggro_range: float = 15.0
@export var attack_range: float = 5.0
@export var damage: int = 10
@export var attack_cooldown: float = 1.5
@export var projectile_scene: PackedScene
@export var projectile_speed: float = 12.0
@export var projectile_spawn_height: float = 1.0

@export_group("Animations")
@export var idle_animation: EnemyAnimation
@export var walk_animation: EnemyAnimation
@export var shoot_animation: EnemyAnimation
@export var death_animation: EnemyAnimation

var _health: int
var _player_ref: Node3D
var _state: State = State.IDLE
var _attack_timer: float = 0.0

@onready var _sprite: EnemyAnimatedSprite = $Sprite


func _ready() -> void:
	_health = max_health
	_sprite.animation_finished.connect(_on_animation_finished)
	if walk_animation != null:
		_sprite.play(walk_animation, &"walk")
	_player_ref = get_tree().get_first_node_in_group("player")


func _physics_process(delta: float) -> void:
	if _state == State.DEAD:
		return

	_attack_timer = maxf(_attack_timer - delta, 0.0)

	if _player_ref == null:
		_player_ref = get_tree().get_first_node_in_group("player")

	if _player_ref == null:
		_do_idle()
		return

	var to_player := _player_ref.global_position - global_position
	to_player.y = 0.0
	var dist := to_player.length()

	if dist > aggro_range:
		_do_idle()
		return

	if dist > attack_range:
		_do_chase(to_player)
		return

	_do_attack(to_player)


func _do_idle() -> void:
	_state = State.IDLE
	velocity = Vector3.ZERO
	move_and_slide()
	if idle_animation != null:
		_sprite.play(idle_animation, &"idle")


func _do_chase(to_player: Vector3) -> void:
	_state = State.CHASE
	var dir := to_player.normalized()
	velocity = dir * move_speed
	move_and_slide()
	if walk_animation != null:
		_sprite.play(walk_animation, &"walk")


func _do_attack(to_player: Vector3) -> void:
	_state = State.ATTACK
	velocity = Vector3.ZERO
	move_and_slide()
	if shoot_animation != null:
		_sprite.play(shoot_animation, &"shoot")
	if _attack_timer > 0.0:
		return
	_fire_projectile(to_player)
	_attack_timer = attack_cooldown


func _fire_projectile(to_player: Vector3) -> void:
	if projectile_scene == null:
		return
	var dir := to_player.normalized()
	var instance := projectile_scene.instantiate() as EnemyProjectile
	if instance == null:
		return
	instance.direction = dir
	instance.speed = projectile_speed
	instance.damage = damage
	get_tree().current_scene.add_child(instance)
	instance.global_position = global_position + Vector3.UP * projectile_spawn_height + dir * 1.0


func Hit_Successful(damage_amount: int, _direction: Vector3 = Vector3.ZERO, _position: Vector3 = Vector3.ZERO) -> void:
	if _state == State.DEAD:
		return
	_health -= damage_amount

	var sound_position := _position
	if sound_position == Vector3.ZERO:
		sound_position = global_position
	_spawn_sound(HIT_SOUND, sound_position)

	if _health > 0:
		return

	_enter_dead()


func _enter_dead() -> void:
	_state = State.DEAD
	velocity = Vector3.ZERO
	_spawn_sound(DESTROY_SOUND, global_position)
	if death_animation == null:
		queue_free()
		return
	_sprite.play(death_animation, &"death")


func _on_animation_finished(anim_name: StringName) -> void:
	if anim_name == &"death":
		queue_free()


func _spawn_sound(stream: AudioStream, pos: Vector3) -> void:
	var player := AudioStreamPlayer3D.new()
	player.stream = stream
	player.bus = "SFX"
	player.global_position = pos
	player.finished.connect(player.queue_free)
	get_tree().current_scene.add_child(player)
	player.play()
