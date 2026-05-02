class_name Enemy
extends CharacterBody3D

const HIT_SOUND := preload("res://assets/audio/Impacto_Enemigo.mp3")
const DESTROY_SOUND := preload("res://assets/audio/Destruccion_Robot.mp3")

enum State { IDLE, CHASE, ATTACK, DEAD }

@export var max_health: int = 100
@export var move_speed: float = 3.0
@export var aggro_range: float = 15.0
@export var attack_range: float = 5.0
@export var range_hysteresis: float = 1.5
@export var damage: int = 10
@export var attack_cooldown: float = 1.5
@export var projectile_scene: PackedScene
@export var projectile_speed: float = 12.0
@export var muzzle: Node3D
@export var target_height_offset: float = 1.0
@export var sidestep_duration: float = 0.5

@export_group("Animations")
@export var idle_animation: EnemyAnimation
@export var walk_animation: EnemyAnimation
@export var shoot_animation: EnemyAnimation
@export var death_animation: EnemyAnimation

var _health: int
var _player_ref: Node3D
var _state: State = State.IDLE
var _attack_timer: float = 0.0
var _gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity", 9.8)
var _sidestep_time_left: float = 0.0
var _sidestep_cooldown: float = 0.0
var _sidestep_dir: Vector3 = Vector3.ZERO

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

	var aggro_exit := aggro_range
	if _state == State.CHASE or _state == State.ATTACK:
		aggro_exit = aggro_range + range_hysteresis

	var attack_exit := attack_range
	if _state == State.ATTACK:
		attack_exit = attack_range + range_hysteresis

	if dist > aggro_exit:
		_do_idle()
		return

	if dist > attack_exit:
		_do_chase(to_player)
		return

	_do_attack(to_player)


func _do_idle() -> void:
	_state = State.IDLE
	velocity.x = 0.0
	velocity.z = 0.0
	_apply_gravity()
	move_and_slide()
	if idle_animation != null:
		_sprite.play(idle_animation, &"idle")


func _do_chase(to_player: Vector3) -> void:
	_state = State.CHASE
	var delta := get_physics_process_delta_time()
	var dir := to_player.normalized()
	_sidestep_time_left = maxf(_sidestep_time_left - delta, 0.0)
	_sidestep_cooldown = maxf(_sidestep_cooldown - delta, 0.0)
	var move_dir := dir
	if _sidestep_time_left > 0.0:
		move_dir = _sidestep_dir
	velocity.x = move_dir.x * move_speed
	velocity.z = move_dir.z * move_speed
	_apply_gravity()
	var pos_before := global_position
	move_and_slide()
	if walk_animation != null:
		_sprite.play(walk_animation, &"walk")
	_maybe_start_sidestep(dir, pos_before, delta)


func _do_attack(to_player: Vector3) -> void:
	_state = State.ATTACK
	velocity.x = 0.0
	velocity.z = 0.0
	_apply_gravity()
	move_and_slide()
	if shoot_animation != null:
		_sprite.play(shoot_animation, &"shoot")
	if _attack_timer > 0.0:
		return
	_fire_projectile()
	_attack_timer = attack_cooldown


func _fire_projectile() -> void:
	if projectile_scene == null:
		return
	if muzzle == null:
		push_warning("Enemy has no muzzle assigned, cannot fire projectile.")
		return
	if _player_ref == null:
		return
	var target := _player_ref.global_position + Vector3.UP * target_height_offset
	var aim := target - muzzle.global_position
	if aim.length_squared() == 0.0:
		return
	var dir := aim.normalized()
	var instance := projectile_scene.instantiate() as EnemyProjectile
	if instance == null:
		return
	instance.direction = dir
	instance.speed = projectile_speed
	instance.damage = damage
	instance.source = self
	get_tree().current_scene.add_child(instance)
	instance.global_position = muzzle.global_position


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


func _apply_gravity() -> void:
	if is_on_floor():
		velocity.y = 0.0
		return
	velocity.y -= _gravity * get_physics_process_delta_time()


func _maybe_start_sidestep(dir: Vector3, pos_before: Vector3, delta: float) -> void:
	if _sidestep_time_left > 0.0:
		return
	if _sidestep_cooldown > 0.0:
		return
	if not is_on_wall():
		return
	var moved := global_position - pos_before
	moved.y = 0.0
	var expected := move_speed * delta * 0.4
	if moved.length() >= expected:
		return
	var perpendicular := Vector3(-dir.z, 0.0, dir.x)
	var sign_chooser := 1.0
	if randi() % 2 == 0:
		sign_chooser = -1.0
	_sidestep_dir = perpendicular * sign_chooser
	_sidestep_time_left = sidestep_duration
	_sidestep_cooldown = sidestep_duration + 0.3


func _spawn_sound(stream: AudioStream, pos: Vector3) -> void:
	var player := AudioStreamPlayer3D.new()
	player.stream = stream
	player.bus = "SFX"
	player.global_position = pos
	player.finished.connect(player.queue_free)
	get_tree().current_scene.add_child(player)
	player.play()
