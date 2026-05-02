extends RigidBody3D

signal hit_successfull

var damage: int = 0
var _lifetime: float = 0.0
var _origin_position: Vector3

@onready var _collision_shape: CollisionShape3D = $CollisionShape3D
@onready var _shape: SphereShape3D = _collision_shape.shape.duplicate()

const BURN_DECAL := preload("res://assets/FPS-Template/Player_Controller/Spawnable_Objects/hit_burn_decal.tscn")

func _ready() -> void:
	for conn in body_entered.get_connections():
		if conn.callable.get_object() != self:
			body_entered.disconnect(conn.callable)
	
	_origin_position = global_position
	_collision_shape.shape = _shape
	
	var mesh := get_node_or_null("plasma_torus_proyectile")
	if mesh != null:
		mesh.inner_radius = 0.174 * 0.5
		mesh.outer_radius = 0.251 * 0.5
	var timer := get_tree().create_timer(3.0)
	timer.timeout.connect(queue_free)

func _process(delta: float) -> void:
	_lifetime += delta
	var mesh := get_node_or_null("plasma_torus_proyectile")
	if mesh == null:
		return
	
	var s := _get_current_scale()
	_shape.radius = 0.15 * s
	
	if _lifetime < 0.2:
		mesh.inner_radius = 0.174 * s
		mesh.outer_radius = 0.251 * s
	else:
		mesh.inner_radius = 0.174 * s
		mesh.outer_radius = 0.251 * s
		mesh.transparency = clampf((_lifetime - 0.2) / 0.1, 0.0, 1.0)
		if mesh.transparency >= 1.0:
			queue_free()

func _on_body_entered(body: Node) -> void:
	_spawn_burn_decal()
	if body.is_in_group("Target") and body.has_method("Hit_Successful"):
		var distance := global_position.distance_to(_origin_position)
		var multiplier := clampf(1.0 - (distance / 50.0), 0.1, 1.0)
		body.Hit_Successful(int(damage * multiplier))
		hit_successfull.emit()
	queue_free()

func _spawn_burn_decal() -> void:
	var space := get_world_3d().direct_space_state
	var from := global_position + linear_velocity.normalized() * 0.2
	var to := global_position - linear_velocity.normalized() * 0.2
	var query := PhysicsRayQueryParameters3D.create(from, to)
	query.collision_mask = collision_mask
	var result := space.intersect_ray(query)
	
	var hit_pos := global_position
	var hit_normal := -linear_velocity.normalized()
	var current_scale := _get_current_scale()
	
	if result:
		hit_pos = result.position
		hit_normal = result.normal
	
	var decal := BURN_DECAL.instantiate() as Decal
	decal.size = Vector3(0.35, 0.35, 0.35) * current_scale
	
	var y := hit_normal
	var x := y.cross(Vector3.UP).normalized()
	if x.is_zero_approx():
		x = Vector3.RIGHT
	var z := x.cross(y)
	decal.global_basis = Basis(x, y, z)
	decal.global_position = hit_pos + hit_normal * 0.01
	
	var world := get_tree().get_first_node_in_group("World")
	if world != null:
		world.add_child(decal)
	else:
		get_tree().get_root().add_child(decal)

func _get_current_scale() -> float:
	if _lifetime < 0.2:
		return lerpf(0.5, 3.0, _lifetime / 0.2)
	return lerpf(3.0, 5.0, (_lifetime - 0.2) / 0.1)
