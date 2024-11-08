extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var file_path = "user://save_game.json"
	if FileAccess.get_file_as_string(file_path) != "":
		print("Found existing save file")
		$Control/ButtonContinue.disabled = false
	else:
		$Control/ButtonContinue.disabled = true
		
	$AudioStreamPlayer2D.play()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_button_quit_game_button_up() -> void:
	$AudioStreamPlayer2D.stop()
	get_tree().quit()


func _on_button_continue_button_up() -> void:
	$AudioStreamPlayer2D.stream = Globals.fx_chop1
	$AudioStreamPlayer2D.play(0.3)
	get_tree().change_scene_to_file("res://battle.tscn")


func _on_button_new_button_up() -> void:
	$AudioStreamPlayer2D.stream = Globals.fx_chop1
	$AudioStreamPlayer2D.play(0.3)
	var file_path = "user://save_game.json"
	if FileAccess.get_file_as_string(file_path) != "":
		print("Found existing save file")
		$Control/PanelDeleteWarning.show()
	else:
		print("Starting new game")
		$AudioStreamPlayer2D.stop()

func _on_button_yes_delete_button_up() -> void:
	$AudioStreamPlayer2D.stream = Globals.fx_chop1
	$AudioStreamPlayer2D.play(0.3)
	var file_path = "user://save_game.json"
	
	var dir_access = DirAccess.open("user://")
	
	if dir_access and dir_access.file_exists(file_path):
		dir_access.remove(file_path)
		
	$AudioStreamPlayer2D.stop()
	get_tree().change_scene_to_file("res://battle.tscn")
	
	
func _on_button_cancel_button_up() -> void:
	$AudioStreamPlayer2D.stream = Globals.fx_chop1
	$AudioStreamPlayer2D.play(0.3)
	$Control/PanelDeleteWarning.hide()
