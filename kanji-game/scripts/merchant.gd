extends Area2D

@export var item_resources: Array[InventoryItem]
@export var _player: Player

@onready var _animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var _dialogue_label: RichTextLabel = $UI/DialogueLabel
@onready var _inventory: GridContainer = $UI/Inventory
@onready var _purchase_sound: AudioStreamPlayer = $PurchaseSound
@onready var _error_sound: AudioStreamPlayer = $ErrorSound
@onready var _target: Marker2D = $Target

signal arrived


func _ready() -> void:
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

		_player.position = _player.position.move_toward(_target.position, 200 * _delta)

		if _player.position == _target.position:
			arrived.emit()

	for i: Button in _inventory.get_children():
		if not i.pressed.is_connected(_on_inventory_button_pressed):
			i.pressed.connect(_on_inventory_button_pressed.bind(i))


func _on_inventory_button_pressed(button: Button) -> void:
	for i in button.get_children():
		if i is Sprite2D:
			for a_name: InventoryItem in item_resources:
				if a_name.item_name.to_lower() == i.name.to_lower() and _player.player_gold >= a_name.price:
					_player.player_gold -= a_name.price
					_purchase_sound.play()

					if a_name.item_name in _player.current_item.keys():
						var cur_item: Dictionary = _player.current_item[a_name.item_name]

						cur_item["amount"] += 1

						_player.update_inventory_ui(_player.indexes_dict[a_name.item_name], button.get_child(0))

					else:
						_player.current_item[a_name.item_name] = {
							"amount": 1,
						}
						_player.indexes_dict[a_name.item_name] = _player.index

						_player.update_inventory_ui(_player.index, button.get_child(0))

						_player.index += 1
				elif _player.player_gold < a_name.price:
					_error_sound.play()
