class_name CharProgress
extends HBoxContainer

@onready var diamond_template: TextureRect = %DiamondTemplate

var enabled_color: Color = Color.WHITE
var disabled_color: Color = Color("#575757")

var moving_diamonds: Array[Control]

func _process(delta: float) -> void:
	for i in moving_diamonds.size():
		moving_diamonds[i].position.y = abs(sin((-Globals.time+i/5.0)*3.0))
		
func set_progress(value: int):
	value = clamp(value,0,6)
	for i in 6:
		var diamond: Control = diamond_template.duplicate()
		if value > 0:
			diamond.modulate = enabled_color
			moving_diamonds.append(diamond)
			value -= 1
		else:
			diamond.modulate = disabled_color
		diamond.visible = true
		add_child(diamond)
