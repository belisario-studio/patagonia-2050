extends CanvasLayer

@onready var overLay = $Overlay

func _on_weapons_manager_update_weapon_stack(_WeaponStack):
	pass

func _on_weapons_manager_update_ammo(_Ammo):
	pass

func _on_weapons_manager_weapon_changed(_WeaponName):
	pass

func _on_weapons_manager_add_signal_to_hud(_projectile):
	pass

func load_over_lay_texture(Active:bool, txtr: Texture2D = null):
		overLay.set_texture(txtr)
		overLay.set_visible(Active)

func _on_weapons_manager_connect_weapon_to_hud(_weapon_resouce: WeaponResource):
	_weapon_resouce.update_overlay.connect(load_over_lay_texture)
