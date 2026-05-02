class_name EnemyAnimatedSprite
extends Sprite3D

signal animation_finished(anim_name: StringName)

var _current: EnemyAnimation
var _current_name: StringName = &""
var _frame: int = 0
var _accum: float = 0.0
var _finished_emitted: bool = false


func play(anim: EnemyAnimation, anim_name: StringName) -> void:
	if anim == null:
		return
	if anim_name == _current_name:
		return
	_current = anim
	_current_name = anim_name
	_frame = 0
	_accum = 0.0
	_finished_emitted = false
	region_enabled = false
	texture = anim.texture
	hframes = maxi(anim.hframes, 1)
	vframes = 1
	frame = 0


func _process(delta: float) -> void:
	if _current == null:
		return
	if _current.fps <= 0.0:
		return
	if _current.hframes < 1:
		return

	var frame_duration := 1.0 / _current.fps
	_accum += delta
	if _accum < frame_duration:
		return

	_accum -= frame_duration

	if _frame + 1 < _current.hframes:
		_frame += 1
		frame = _frame
		return

	if _current.loop:
		_frame = 0
		frame = _frame
		return

	if _finished_emitted:
		return

	_finished_emitted = true
	animation_finished.emit(_current_name)
