extends Node
@export var default_level = 0
var curr_level: BaseLevel = null  


func load_level(level = null):  
	if level == null: 
		level = default_level
	if level < 0 or level > 5: 
		print("LevelManager error: only allow levels from 1 to 5")
		
	var base_path = "res://scenes/Levels/"
	if level == 0: 
		base_path += "BaseLevel.tscn" 
	else: 
		if(!Globals.purchased_lvls.has(level)):
			print("Please purchase the level: ", level)
			return null
		base_path += "Level" + str(level) +  ".tscn"
		
	if curr_level != null: 
		curr_level.queue_free()
		
	curr_level = load(base_path).instantiate()
	add_child(curr_level)
	return curr_level
