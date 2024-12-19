extends Control

const CHAR_PROGRESS = preload("res://scenes/char_progress.tscn")

@onready var char_list: VBoxContainer = %char
@onready var read_progress: VBoxContainer = %read_progress
@onready var write_progress: VBoxContainer = %write_progress
enum CHAR_STATE {
	READ,
	WRITE
}

func _ready() -> void:
	show_chars()

func add_char(char: String, r_progress: int, w_progress: int) -> void:
	var label: Label = Label.new()
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.text = char
	char_list.add_child(label)
	add_progress(r_progress,0)
	add_progress(w_progress,1)

func add_progress(value: int, state: CHAR_STATE):
	var progress: CharProgress = CHAR_PROGRESS.instantiate()
	match state:
		0:
			read_progress.add_child(progress)
		1:
			write_progress.add_child(progress)
	progress.set_progress(value)
	
func load_chars() -> Dictionary:
	var file_path_save: String = "user://save_game.json"
	var save_json_as_text: String = FileAccess.get_file_as_string(file_path_save)
	if save_json_as_text != "":
		var save_data = JSON.parse_string(save_json_as_text)
		if save_data.has("slot0"):
			return save_data.slot0.progress
	return {}

func show_chars() -> void:
	var chars: Dictionary = load_chars()
	for char in chars:
		add_char(char,chars.get(char).r,chars.get(char).w)
