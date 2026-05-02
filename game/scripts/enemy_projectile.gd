class_name EnemyProjectile
extends Area3D

@export var damage: int = 10
@export var speed: float = 12.0
@export var lifetime: float = 4.0

var direction: Vector3 = Vector3.FORWARD
var source: Node = null


func _ready() -> void:
	body_entered.connect(_on_body_entered)
	var timer := get_tree().create_timer(lifetime)
	timer.timeout.connect(_safe_queue_free)


func _physics_process(delta: float) -> void:
	global_position += direction * speed * delta


func _on_body_entered(body: Node) -> void:
	if body == source:
		return
	if body.is_in_group("player") and body.has_method("Hit_Successful"):
		body.Hit_Successful(damage, direction, global_position)
	queue_free()


func _safe_queue_free() -> void:
	if is_inside_tree():
		queue_free()
