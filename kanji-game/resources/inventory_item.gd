@tool

extends Resource
class_name InventoryItem

@export var price: int = 5
@export var health_given: int = 5
@export var item_name: String = "":
	set(new_name):
		new_name = new_name.to_lower()
		item_name = new_name
