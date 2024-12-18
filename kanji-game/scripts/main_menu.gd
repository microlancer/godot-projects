extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	
	var file_path = "user://settings.json"
	var save_json_as_text = FileAccess.get_file_as_string(file_path)
	
	if  save_json_as_text != "":
		print("Found existing settings file")
		var settings_data = JSON.parse_string(save_json_as_text)
		print(save_json_as_text)
		
		if settings_data.has("bg_music_enabled"):
			Globals.custom_bg_music_enabled = settings_data.bg_music_enabled
		else:
			Globals.custom_bg_music_enabled = true
		
		if settings_data.has("player_name"):
			Globals.player_name = settings_data.player_name
		else:
			Globals.player_name = "プレイヤー"
	else:
		Globals.custom_bg_music_enabled = true
		Globals.player_name = "プレイヤー"
		
	if not Globals.AudioStreamPlayerBgMusic.stream:
		Globals.AudioStreamPlayerBgMusic.stream = preload("res://assets/music/Ambient 1-LQ.mp3")
		#add_child(Globals.AudioStreamPlayerBgMusic)
		
	if Globals.custom_bg_music_enabled and not Globals.AudioStreamPlayerBgMusic.is_playing():
		Globals.AudioStreamPlayerBgMusic.play()
		
	var file_path_save_game = "user://save_game.json"
	var save_json_as_text_save_game = FileAccess.get_file_as_string(file_path_save_game)
	if  save_json_as_text_save_game != "":
		print("Found existing save game file")
		$Control/ButtonContinue.disabled = false
	else:
		$Control/ButtonContinue.disabled = true
		


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_button_quit_game_button_up() -> void:
	get_tree().quit()


func _on_button_continue_button_up() -> void:
	Globals.AudioStreamPlayerSoundFx.stream = Globals.fx_chop1
	Globals.AudioStreamPlayerSoundFx.play(0.3)
	get_tree().change_scene_to_file("res://scenes/battle.tscn")


func _on_button_new_button_up() -> void:
	Globals.AudioStreamPlayerSoundFx.stream = Globals.fx_chop1
	Globals.AudioStreamPlayerSoundFx.play(0.3)
	var file_path = "user://save_game.json"
	if FileAccess.get_file_as_string(file_path) != "":
		print("Found existing save file")
		$Control/PanelDeleteWarning.show()
	else:
		print("Starting new game")
		get_tree().change_scene_to_file("res://scenes/battle.tscn")
		$AudioStreamPlayer2D.stop()

func _on_button_yes_delete_button_up() -> void:
	Globals.AudioStreamPlayerSoundFx.stream = Globals.fx_chop1
	Globals.AudioStreamPlayerSoundFx.play(0.3)
	var file_path = "user://save_game.json"
	
	var dir_access = DirAccess.open("user://")
	
	if dir_access and dir_access.file_exists(file_path):
		dir_access.remove(file_path)
		
	$AudioStreamPlayer2D.stop()
	get_tree().change_scene_to_file("res://scenes/battle.tscn")
	
	
func _on_button_cancel_button_up() -> void:
	Globals.AudioStreamPlayerSoundFx.stream = Globals.fx_chop1
	Globals.AudioStreamPlayerSoundFx.play(0.3)
	$Control/PanelDeleteWarning.hide()


func _on_menu_menu_button_button_up() -> void:
	Globals.AudioStreamPlayerSoundFx.stream = Globals.fx_chop1
	Globals.AudioStreamPlayerSoundFx.play(0.3)
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")


func _on_button_settings_button_up() -> void:
	Globals.AudioStreamPlayerSoundFx.stream = Globals.fx_chop1
	Globals.AudioStreamPlayerSoundFx.play(0.3)
	get_tree().change_scene_to_file("res://scenes/settings.tscn")
