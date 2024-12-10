extends Node2D

@export var BgMusic: AudioStreamPlayer

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	print("Music: " + str(Globals.custom_bg_music_enabled))
	if Globals.custom_bg_music_enabled:
		$Control/CheckBoxBgMusic.button_pressed = true
	else:
		$Control/CheckBoxBgMusic.button_pressed = false

	$Control/TextEditPlayerName.text = Globals.player_name
	$Control/TextEditCustomSkipKanjiList.text = Globals.custom_skip_kanji_list

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_check_box_bg_music_button_up() -> void:
	Globals.custom_bg_music_enabled = $Control/CheckBoxBgMusic.button_pressed
	print("Music: " + str(Globals.custom_bg_music_enabled))
	print("Pressed: " + str($Control/CheckBoxBgMusic.button_pressed))
	if Globals.custom_bg_music_enabled:
		Globals.AudioStreamPlayerBgMusic.volume_db = 0
		if not Globals.AudioStreamPlayerBgMusic.is_playing():
			Globals.AudioStreamPlayerBgMusic.play()
	else:
		Globals.AudioStreamPlayerBgMusic.volume_db = -999

	Globals.save_settings()


func _on_menu_menu_button_button_up() -> void:
	Globals.AudioStreamPlayerSoundFx.stream = Globals.fx_chop1
	Globals.AudioStreamPlayerSoundFx.play(0.3)
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")


func _on_text_edit_player_name_text_changed() -> void:
	Globals.player_name = $Control/TextEditPlayerName.text
	Globals.save_settings()


func _on_text_edit_custom_skip_kanji_list_text_changed() -> void:
	Globals.custom_skip_kanji_list = $Control/TextEditCustomSkipKanjiList.text
	Globals.save_settings()
