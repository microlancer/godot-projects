@tool

extends Resource
class_name InventoryItem

@export var price: int = 5
@export var health_given: int = 5
@export var displayTexture: Texture2D = null
@export var item_name: String = "":
	set(new_name):
		new_name = new_name.to_lower()
		item_name = new_name
# number of turn before expiry
@export var turns_left = 1 : set = set_turns_left
signal expired 



func set_turns_left(val): 
	turns_left = val 
	if turns_left < 0: 
		expired.emit() 

func customEffect(payload): 
	pass

func cleanupEffect(context):
	pass

func applyEffect(context): 
	pass
