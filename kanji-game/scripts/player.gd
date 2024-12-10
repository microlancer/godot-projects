extends AnimatedSprite2D
class_name Player

@onready var _label: Label = $CanvasLayer/Label

@export var speed: float = 300.0

var _last_movement_x := 0.0
var _player_gold: int = 0.0:
	set(new_amount):
		_player_gold = new_amount

		_label.text = ": " + str(_player_gold)


func _ready() -> void:
	_player_gold = 75


func _process(delta: float) -> void:
	var x_axis := Input.get_axis("move_left", "move_right")

	if x_axis != 0.0:
		_last_movement_x = x_axis

	position.x += x_axis * speed * delta

	if x_axis != 0.0:
		play("run")
	else:
		play("idle")

	flip_h = _last_movement_x < 0
