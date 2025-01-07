extends Resource
class_name DropItemComponent

@export var itemsPercentage: Array[ItemPercentageType]

var rng = RandomNumberGenerator.new()
func _ready() -> void: 
	rng.randomize() 

func spawnItem()->InventoryItem: 
	# pick items based on their percent
	var candidates = [] 
	for _item in itemsPercentage: 
		if Globals.pick_percent(_item.percentage): 
			candidates.append(_item.item)
	
	# no items
	if candidates.size() == 0: 
		return null

	return candidates[rng.randi()%candidates.size()]
