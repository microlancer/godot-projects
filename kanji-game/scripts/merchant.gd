extends Area2D

@export var item_resources: Array[InventoryItem]

@onready var _player: Player = $Player
@onready var _animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var _dialogue_label: RichTextLabel = $UI/DialogueLabel
@onready var _inventory: GridContainer = $UI/Inventory
@onready var _purchase_sound: AudioStreamPlayer = $PurchaseSound
@onready var _error_sound: AudioStreamPlayer = $ErrorSound
@onready var _target: Marker2D = $Target
@onready var InventoryButtonScene = preload("res://scenes/InventoryButton.tscn") 

signal arrived


func loadItems(): 
	for item in item_resources: 
		var button:Button = InventoryButtonScene.instantiate()
		button.get_node("Label").text = "G:"+str(item.price)
		_inventory.add_child(button)
		button.get_node("Sprite").texture = item.displayTexture
		button.pressed.connect(Callable(self,"_on_inventory_button_pressed").bind(item))
		
func _ready() -> void:
	loadItems()
	_player.play("run")

	arrived.connect(
		func () -> void:
			_player.play("idle")

			_dialogue_label.text = "What can I get ya? I got the best deals in town."

			_dialogue_label.visible_ratio = 0.0

			var tween := create_tween().tween_property(_dialogue_label, "visible_ratio", 1.0, 1.0)

			tween.finished.connect(
				func () -> void:
					_dialogue_label.hide()
					_inventory.show()
			)
	)


func _process(_delta: float) -> void:
	if _player != null:
		_animated_sprite_2d.flip_h = _player.global_position.x < global_position.x

		_player.position.x = move_toward(_player.position.x, _target.position.x, 200 * _delta)

		if _player.position.x == _target.position.x:
			arrived.emit()

	for i: Button in _inventory.get_children():
		if not i.pressed.is_connected(_on_inventory_button_pressed):
			i.pressed.connect(_on_inventory_button_pressed.bind(i))


func _on_inventory_button_pressed(selected_item: InventoryItem) -> void:
	if _player.player_gold >= selected_item.price:
		_player.player_gold -= selected_item.price
		_purchase_sound.play()
#
		if selected_item.item_name in _player.current_item.keys():
			var cur_item: Dictionary = _player.current_item[selected_item.item_name]
#
			cur_item["amount"] += 1
#
			_player.update_inventory_ui(_player.indexes_dict[selected_item.item_name], selected_item.displayTexture)
#
		else:
			_player.current_item[selected_item.item_name] = {
				"amount": 1,
			}
			_player.indexes_dict[selected_item.item_name] = _player.index
#
			_player.update_inventory_ui(_player.index, selected_item.displayTexture)

			_player.index += 1
	elif _player.player_gold < selected_item.price:
		_error_sound.play()
