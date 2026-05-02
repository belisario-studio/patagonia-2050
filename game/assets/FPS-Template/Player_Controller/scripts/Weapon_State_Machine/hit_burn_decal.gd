extends Decal

@onready var _timer := $Timer

func _ready() -> void:
	_timer.timeout.connect(queue_free)
