extends LoadingScreen


func _ready() -> void:
	_apply_visual_styles()


func _apply_visual_styles() -> void:
	var control := $Control

	var back_panel := control.get_node_or_null("BackPanel")
	if back_panel:
		back_panel.hide()

	var bg := ColorRect.new()
	bg.color = Color(0.02, 0.03, 0.05, 1.0)
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	control.add_child(bg)
	control.move_child(bg, 0)

	var bar: ProgressBar = %ProgressBar
	var bar_bg := StyleBoxFlat.new()
	bar_bg.bg_color = Color(0.08, 0.08, 0.12, 1.0)
	bar_bg.set_corner_radius_all(2)
	bar.add_theme_stylebox_override("background", bar_bg)

	var bar_fill := StyleBoxFlat.new()
	bar_fill.bg_color = Color(0.0, 0.85, 1.0, 1.0)
	bar_fill.set_corner_radius_all(2)
	bar.add_theme_stylebox_override("fill", bar_fill)

	bar.add_theme_constant_override("outline_size", 0)

	var label: Label = %ProgressLabel
	label.add_theme_color_override("font_color", Color(0.0, 0.85, 1.0, 1.0))
	label.add_theme_font_size_override("font_size", 24)

	var robot := TextureRect.new()
	robot.texture = preload("res://assets/robot.png")
	robot.expand_mode = TextureRect.EXPAND_FIT_WIDTH
	robot.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	robot.custom_minimum_size = Vector2(120, 120)
	robot.set_anchors_preset(Control.PRESET_CENTER_TOP)
	robot.position = Vector2(robot.position.x, 60)
	control.add_child(robot)
