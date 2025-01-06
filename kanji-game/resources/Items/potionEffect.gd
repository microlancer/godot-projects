extends "res://resources/inventory_item.gd"

func applyEffect(context:Main):
	context.player_hp += health_given
	if context.player_hp > context.player_hp_max: 
		context.player_hp = context.player_hp_max
	context.update_hp()
	turns_left -= 1
