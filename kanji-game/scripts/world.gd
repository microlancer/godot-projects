extends Node2D
class_name  World 

@export var Player: Player 
@export var NonPlayableCharacter:AnimatedSprite2D
@export var Player_health_label:Label
@export var Enemy_health_label:Label
@export var player_health_bar:ProgressBar
@export var enemy_health_bar:ProgressBar
@export var level:int = 0

@onready var world_tile_map_layer:TileMapLayer = $TileMapLayer
@onready var Decor1:Sprite2D = $Decors
@onready var Decor2:Sprite2D = $Decors2

@onready var AudioPlayer:AudioStreamPlayer2D = $AudioStreamPlayer2D
@onready var UI:Control = $UI
@onready var rng = RandomNumberGenerator.new()

signal end_run_to_npc()
signal end_run_from_npc()


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Player.position.x = -50
	reset_decor_positions()
	UI.hide()
	fade_in_and_run_to_npc()
	
	if false:
		var timer = Timer.new()
		timer.wait_time = 4
		timer.one_shot = true  # Makes the timer run only once
		add_child(timer)
		timer.timeout.connect(Callable(self, "fade_out_and_run_from_npc"))
		timer.start()
	
	if false:
		var timer = Timer.new()
		timer.wait_time = 4
		timer.one_shot = true  # Makes the timer run only once
		add_child(timer)
		timer.timeout.connect(Callable(self, "run_to_next_npc"))
		timer.start()
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func spawn_enemy(elist: Array[EnemyResource], spawnBoss = false):
	# spawn bosses or normal enemies
	if(!spawnBoss):
		elist = elist.filter(func(e): return !e.isBoss)
	else:
		elist = elist.filter(func(e): return e.isBoss)
		
	
	if elist.size() == 0: 
		printerr("Enemies options must be more than 1!")
		return null
	
	# pick enemy
	var enem = elist[rng.randi()%elist.size()]

	# spawn enemy
	NonPlayableCharacter = $EnemyUtil.create_enemy_from_res(enem)	
	$EnemyPos.position = enem.enemy_pos
	$EnemyPos.add_child(NonPlayableCharacter)
	NonPlayableCharacter.animation = "enemy_idle"
	NonPlayableCharacter.play()
	return NonPlayableCharacter
	 

	
func fade_in_and_run_to_npc() -> void:
	Player.animation = "run"
	Player.play()

	AudioPlayer.stream = Globals.fx_dirt_run1
	AudioPlayer.stream.loop = true
	AudioPlayer.play()
	var tween = create_tween()
	var time_sec = 2
	tween.connect("finished", Callable(self, "_end_run_to_npc"))
	tween.parallel().tween_property(
		Player, "position:x", 44, time_sec
	)
	tween.parallel().tween_property(world_tile_map_layer, "position:x", -90, time_sec)
	tween.parallel().tween_property(Decor1, "position:x", 80, time_sec)
	tween.parallel().tween_property(Decor2, "position:x", -80, time_sec)

	tween.parallel().tween_property(NonPlayableCharacter, "position:x", 76, time_sec)

func reset_decor_positions():
	world_tile_map_layer.position.x = 90
	Decor1.position.x = 245
	Decor2.position.x = 80	

func _end_run_to_npc() -> void:
	reset_decor_positions()
	Player.animation = "idle"
	AudioPlayer.stop()
	end_run_to_npc.emit()
	
func _end_run_from_npc() -> void:
	reset_decor_positions()
	Player.animation = "idle"
	AudioPlayer.stop()
	end_run_from_npc.emit()
	
func fade_out_and_run_from_npc() -> void:
	Player.animation = "run"
	Player.flip_h = true
	Player.play()
	AudioPlayer.stream = Globals.fx_dirt_run1
	AudioPlayer.stream.loop = true
	AudioPlayer.play()
	var tween = create_tween()
	var time_sec = 2
	tween.connect("finished", Callable(self, "_end_run_from_npc"))
	tween.parallel().tween_property(
		Player, "position:x", -50, time_sec
	)
	tween.parallel().tween_property(world_tile_map_layer, "position:x", 90, time_sec)
	tween.parallel().tween_property(Decor2, "position:x", 245, time_sec)
	tween.parallel().tween_property(Decor1, "position:x", 80, time_sec)

	tween.parallel().tween_property(NonPlayableCharacter, "position:x", 300, time_sec)

func run_to_next_npc():
	Player.animation = "run"
	Player.play()
	NonPlayableCharacter.position.x = 300
	NonPlayableCharacter.animation = "enemy_idle"
	NonPlayableCharacter.play()
	NonPlayableCharacter.show()
	AudioPlayer.stream = Globals.fx_dirt_run1
	AudioPlayer.stream.loop = true
	AudioPlayer.play()
	var tween = create_tween()
	var time_sec = 2
	tween.connect("finished", Callable(self, "_end_run_to_npc"))
	tween.parallel().tween_property(
		Player, "position:x", 44, time_sec
	)
	tween.parallel().tween_property(world_tile_map_layer, "position:x", -90, time_sec)
	tween.parallel().tween_property(Decor1, "position:x", 80, time_sec)
	tween.parallel().tween_property(Decor2, "position:x", -80, time_sec)

	tween.parallel().tween_property(NonPlayableCharacter, "position:x", 76, time_sec)
