extends RigidBody3D

var damage: int = 0
var _lifetime: float = 0.0

@onready var _collision_shape: CollisionShape3D = $CollisionShape3D
@onready var _shape: SphereShape3D = _collision_shape.shape.duplicate()

func _ready() -> void:
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
	
	var s := get_current_scale()
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

func get_current_scale() -> float:
	if _lifetime < 0.2:
		return lerpf(0.5, 3.0, _lifetime / 0.2)
	return lerpf(3.0, 5.0, (_lifetime - 0.2) / 0.1)
