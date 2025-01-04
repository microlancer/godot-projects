extends AnimatedSprite2D
class_name Player

@onready var _label: Label = $UI/Label
@onready var _inventory_ui: GridContainer = $Control/InventoryUI
var weapon_dmg = 1

signal used_item
signal test


var player_gold: int = 0:
	set(new_amount):
		player_gold = new_amount

		_label.text = ": " + str(player_gold)

# sample 
var holding_items = { 
	#"name": { 
		#"ui_idx": 0, 
		#"item_obj":InventoryItem, 
		#"amount":0
	#}
}
#var holding_items: Dictionary
#var max_inven_size = 9



func _ready() -> void:
	player_gold = 75
	# on click use item
	for but in _inventory_ui.get_children(): 
		but.connect("pressed",Callable(self, "_on_item_pressed").bind(but.get_index()))

func _on_item_pressed(idx: int): 
	for item in holding_items.values():
		if item["ui_idx"] == idx: 
			# use item 
			used_item.emit(item["item_obj"])
			
			# after use 
			item["amount"] -= 1

			# update dict and ui 
			update_inventory_ui(item["item_obj"].item_name)
			if item["amount"] == 0: 
				holding_items.erase(item["item_obj"].item_name)	
	
func update_inventory_ui(item_name: String) -> void:
	var item_to_update = holding_items.get(item_name)
	if item_to_update != null:
		var current_button: Button = _inventory_ui.get_child(item_to_update["ui_idx"])
		var current_sprite: Sprite2D = current_button.get_child(0)

		var amount = item_to_update["amount"]
		if amount == 0: 
			current_sprite.texture = null
			current_button.get_child(1).text = ""
			return 
			
		current_button.get_child(1).text = str(amount)
		current_sprite.texture = item_to_update["item_obj"].displayTexture
		#current_sprite.region_enabled = sprite.region_enabled
		#current_sprite.region_rect = sprite.region_rect
		current_sprite.scale = Vector2.ONE * 0.5

func _on_inventory_button_pressed() -> void:
	_inventory_ui.visible = not _inventory_ui.visible




func get_empty_idx(): 
	var options = range(0,10) # array from 0 -> 9
	for item in holding_items.values(): 
		if options.has(item["ui_idx"]): 
			# filter out the option contain ui_idx 
			options = options.filter(func(o): return o != item["ui_idx"])
			
	if options.size() == 0: 
		return -1 
	return options[0]

func buy_item(selected_item: InventoryItem) -> bool: 
	if player_gold < selected_item.price:
		return false 

	player_gold -= selected_item.price
#
	if selected_item.item_name in holding_items.keys(): 
		var cur_item: Dictionary = holding_items[selected_item.item_name]
		cur_item["amount"] += 1
#
		update_inventory_ui(selected_item.item_name)
#
	else:
		var next_idx = get_empty_idx() 
		if next_idx == -1: 
			print("No space left!!") 
			return false 
			
		holding_items[selected_item.item_name] = {
			"amount": 1,
			"ui_idx": next_idx,
			"item_obj": selected_item
		}
		update_inventory_ui(selected_item.item_name)
	return true
	
	
