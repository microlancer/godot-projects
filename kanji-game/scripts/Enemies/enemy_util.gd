extends Node
class_name EnemyUtil
var allowedEnemies = ["skeleton", "snake", "cat", "bat", "crow", "tree"]


func create_enemy(t: String)->AnimatedSprite2D: 
	# sanitize
	if !allowedEnemies.has(t):
		printerr("Spawned not allowed enemy: ", t)
		return null
	
	# load enemy resource
	# res://resources/Enemies/skeleton.tres for e.g for skeleton resource
	var baseResPath = "res://resources/Enemies/"
	var res: EnemyResource = load(baseResPath + t + ".tres")
	
	# create enemy
	var node: BaseEnemy = BaseEnemy.new(res)

	return node
