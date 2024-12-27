extends AnimatedSprite2D
class_name BaseEnemy

@export var base_dmg = 0 
@export var base_hp = 0

func _init(res: EnemyResource):
	base_dmg = res.base_dmg
	base_hp = res.base_hp
