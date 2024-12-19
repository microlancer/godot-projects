extends Control


func _on_button_battle_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/battle.tscn")


func _on_button_merchant_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/merchant.tscn")


func _on_menu_menu_button_pressed() -> void:
	Globals.AudioStreamPlayerBgMusic.stop()
	Globals.AudioStreamPlayerBgMusic.stream = null
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")
