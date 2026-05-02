extends MainMenu


func load_game_scene() -> void:
	GameState.start_game()
	super.load_game_scene()


func new_game() -> void:
	GameState.reset()
	load_game_scene()


func _ready() -> void:
	super._ready()
