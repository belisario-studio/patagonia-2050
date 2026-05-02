extends AudioStreamPlayer

func _ready() -> void:
	if stream == null:
		return
	stream.set("loop", true)
