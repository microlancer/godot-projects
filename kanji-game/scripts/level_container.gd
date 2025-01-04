extends Node
@export var default_level = 0
var curr_level: BaseLevel = null  


func load_level(level = null):  
	if level == null: 
		level = default_level
		
	var base_path = "res://scenes/Levels/"
	if level == 0: 
		base_path += "BaseLevel.tscn" 
	else: 
		base_path += "Level1.tscn"
	
	curr_level = load(base_path).instantiate()
	add_child(curr_level)
	return curr_level
