extends MainMenu

var animation_state_machine: AnimationNodeStateMachinePlayback


func load_game_scene() -> void:
	GameState.start_game()
	super.load_game_scene()


func new_game() -> void:
	GameState.reset()
	load_game_scene()


func intro_done() -> void:
	animation_state_machine.travel("OpenMainMenu")


func _is_in_intro() -> bool:
	return animation_state_machine.get_current_node() == "Intro"


func _event_skips_intro(event: InputEvent) -> bool:
	return event.is_action_released("ui_accept") or \
		event.is_action_released("ui_select") or \
		event.is_action_released("ui_cancel") or \
		_event_is_mouse_button_released(event)


func _open_sub_menu(menu: PackedScene) -> Node:
	animation_state_machine.travel("OpenSubMenu")
	return super._open_sub_menu(menu)


func _close_sub_menu() -> void:
	super._close_sub_menu()
	animation_state_machine.travel("OpenMainMenu")


func _input(event: InputEvent) -> void:
	if _is_in_intro() and _event_skips_intro(event):
		intro_done()
		return
	super._input(event)


func _ready() -> void:
	super._ready()
	animation_state_machine = $MenuAnimationTree.get("parameters/playback")
	_apply_visual_styles()


func _apply_visual_styles() -> void:
	var cyan := Color(0.0, 0.85, 1.0, 1.0)
	var dark_bg := Color(0.05, 0.05, 0.08, 0.7)

	var bg_texture := $BackgroundTextureRect
	if bg_texture:
		bg_texture.hide()

	var color_rect := ColorRect.new()
	color_rect.color = Color(0.02, 0.03, 0.05, 1.0)
	color_rect.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(color_rect)
	move_child(color_rect, 0)

	var title_margin := $MenuContainer/TitleMargin
	title_margin.visible = true
	var title_label := $MenuContainer/TitleMargin/TitleContainer/TitleLabel
	title_label.add_theme_color_override("font_color", cyan)
	title_label.add_theme_font_size_override("font_size", 56)

	var sub_title_margin := $MenuContainer/SubTitleMargin
	sub_title_margin.visible = true
	var sub_title_label := $MenuContainer/SubTitleMargin/SubTitleContainer/SubTitleLabel
	sub_title_label.text = "DEMO BUILD"
	sub_title_label.add_theme_color_override("font_color", Color(0.8, 0.8, 0.8, 0.6))
	sub_title_label.add_theme_font_size_override("font_size", 20)

	var box := $MenuContainer/MenuButtonsMargin/MenuButtonsContainer/MenuButtonsBoxContainer
	box.add_theme_constant_override("separation", 20)

	for child in box.get_children():
		if child is Button:
			_style_button(child, cyan, dark_bg)


func _style_button(button: Button, cyan: Color, dark_bg: Color) -> void:
	var normal := StyleBoxFlat.new()
	normal.bg_color = dark_bg
	normal.border_color = cyan
	normal.set_border_width_all(2)
	normal.set_corner_radius_all(4)
	button.add_theme_stylebox_override("normal", normal)

	var hover := StyleBoxFlat.new()
	hover.bg_color = Color(cyan.r, cyan.g, cyan.b, 0.15)
	hover.border_color = cyan
	hover.set_border_width_all(2)
	hover.set_corner_radius_all(4)
	button.add_theme_stylebox_override("hover", hover)

	var pressed := StyleBoxFlat.new()
	pressed.bg_color = Color(cyan.r, cyan.g, cyan.b, 0.35)
	pressed.border_color = cyan
	pressed.set_border_width_all(2)
	pressed.set_corner_radius_all(4)
	button.add_theme_stylebox_override("pressed", pressed)

	button.add_theme_color_override("font_color", Color(0.9, 0.9, 0.9, 1.0))
	button.add_theme_color_override("font_hover_color", cyan)
	button.add_theme_color_override("font_pressed_color", Color(1.0, 1.0, 1.0, 1.0))
	button.add_theme_font_size_override("font_size", 22)
