extends LoadingScreen


func _ready() -> void:
	_apply_visual_styles()


func _apply_visual_styles() -> void:
	var control := $Control
	control.theme = preload("res://resources/themes/ui_theme.tres")

	var back_panel := control.get_node_or_null("BackPanel")
	if back_panel:
		back_panel.hide()

	var bg := ColorRect.new()
	bg.color = Color(0.02, 0.03, 0.05, 1.0)
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	control.add_child(bg)
	control.move_child(bg, 0)

	var bar: ProgressBar = %ProgressBar
	bar.add_theme_constant_override("outline_size", 0)

	var label: Label = %ProgressLabel
	label.add_theme_font_size_override("font_size", 24)

	var robot := TextureRect.new()
	robot.texture = preload("res://assets/robot.png")
	robot.expand_mode = TextureRect.EXPAND_FIT_WIDTH
	robot.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	robot.custom_minimum_size = Vector2(120, 120)
	robot.set_anchors_preset(Control.PRESET_CENTER_TOP)
	robot.position = Vector2(robot.position.x, 60)
	control.add_child(robot)
