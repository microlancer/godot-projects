extends AnimatedSprite2D
class_name Player

@onready var _label: Label = $UI/Label
@onready var _inventory_ui: GridContainer = $Control/InventoryUI

var player_gold: int = 0:
	set(new_amount):
		player_gold = new_amount

		_label.text = ": " + str(player_gold)

var current_item: Dictionary
var indexes_dict: Dictionary
var index: int = 0


func _ready() -> void:
	player_gold = 75


func update_inventory_ui(index_to_update: int, sprite: Sprite2D) -> void:
	for i: String in indexes_dict:
		if indexes_dict[i] == index_to_update:
			var current_button: Button = _inventory_ui.get_child(index_to_update)
			var current_sprite: Sprite2D = current_button.get_child(0)

			current_button.get_child(1).text = str(current_item[i]["amount"])
			current_sprite.texture = sprite.texture
			current_sprite.region_enabled = sprite.region_enabled
			current_sprite.region_rect = sprite.region_rect
			current_sprite.scale = sprite.scale


func _on_inventory_button_pressed() -> void:
	_inventory_ui.visible = not _inventory_ui.visible


func _on_menu_menu_button_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/town.tscn")
