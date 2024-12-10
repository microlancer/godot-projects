extends Area2D

@onready var _animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var _dialogue_label: RichTextLabel = $UI/DialogueLabel
@onready var _inventory: GridContainer = $UI/Inventory

var _player: Player


func _process(_delta: float) -> void:
	if _player != null:
		_animated_sprite_2d.flip_h = _player.global_position.x < global_position.x

		_dialogue_label.visible_ratio = 0.0

		_dialogue_label.text = "What can I get ya? I got the best deals in town."

		var tween := create_tween().tween_property(_dialogue_label, "visible_ratio", 1.0, 1.2)

		tween.finished.connect(
			func () -> void:
				await get_tree().create_timer(1.5, false).timeout
				_dialogue_label.hide()
				_inventory.show()
		)


func _on_area_entered(area: Area2D) -> void:
	if area.get_parent() is Player:
		_player = area.get_parent()
