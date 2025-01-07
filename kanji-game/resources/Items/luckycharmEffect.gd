extends "res://resources/inventory_item.gd"
var streak = 0 

func applyEffect(context:Main):
	var extra_gold = 1 + streak/3
	context.player_gold += extra_gold
	turns_left -= 1 

func customEffect(payload): 
	if payload == "lose_streak": 
		streak = 0
