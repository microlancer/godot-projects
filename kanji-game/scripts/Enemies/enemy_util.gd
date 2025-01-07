extends Node
class_name EnemyUtil
const allowedEnemies = ["skeleton", "snake", "cat", "bat", "crow", "tree"]


func create_enemy_from_res(res: EnemyResource): 
	# create enemy
	var node: BaseEnemy = BaseEnemy.new(res)
	node.flip_h = res.flip_h

	return node
	
func create_enemy_from_str(t: String)->AnimatedSprite2D: 
	# sanitize
	if !allowedEnemies.has(t):
		printerr("Spawned not allowed enemy: ", t)
		return null
	
	# load enemy resource
	# res://resources/Enemies/skeleton.tres for e.g for skeleton resource
	var baseResPath = "res://resources/Enemies/"
	var res: EnemyResource = load(baseResPath + t + ".tres")
	return create_enemy_from_res(res)
