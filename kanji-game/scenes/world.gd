extends Node2D

@onready var animated_player = $WorldObjects/AnimatedPlayer
@onready var animated_npc = $WorldObjects/AnimatedNpc

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	animated_player.position.x = -50
	$WorldObjects/AnimatedNpc.position.x = 300
	$WorldObjects/UI.hide()
	fade_in_and_run_to_npc()
	
	var timer = Timer.new()
	timer.wait_time = 4
	timer.one_shot = true  # Makes the timer run only once
	add_child(timer)
	timer.timeout.connect(Callable(self, "run_away"))
	timer.start()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
	
func fade_in_and_run_to_npc() -> void:
	animated_player.animation = "run"
	animated_player.play()
	$AudioStreamPlayer2D.stream = Globals.fx_dirt_run1
	$AudioStreamPlayer2D.stream.loop = true
	$AudioStreamPlayer2D.play()
	var tween = create_tween()
	var time_sec = 2
	tween.connect("finished", Callable(self, "_end_run"))
	tween.parallel().tween_property(
		animated_player, "position:x", 50, time_sec
	)
	tween.parallel().tween_property($WorldObjects/TileMapLayer, "position:x", -90, time_sec)
	tween.parallel().tween_property($WorldObjects/Trees2, "position:x", 80, time_sec)
	tween.parallel().tween_property($WorldObjects/Trees, "position:x", -80, time_sec)

	tween.parallel().tween_property(animated_npc, "position:x", 85, time_sec)
	
func _end_run() -> void:
	animated_player.animation = "idle"
	$AudioStreamPlayer2D.stop()
	
func run_away() -> void:
	animated_player.animation = "run"
	animated_player.flip_h = true
	animated_player.play()
	$AudioStreamPlayer2D.stream = Globals.fx_dirt_run1
	$AudioStreamPlayer2D.stream.loop = true
	$AudioStreamPlayer2D.play()
	var tween = create_tween()
	var time_sec = 2
	tween.connect("finished", Callable(self, "_end_run"))
	tween.parallel().tween_property(
		animated_player, "position:x", -50, time_sec
	)
	tween.parallel().tween_property($WorldObjects/TileMapLayer, "position:x", 90, time_sec)
	tween.parallel().tween_property($WorldObjects/Trees2, "position:x", 245, time_sec)
	tween.parallel().tween_property($WorldObjects/Trees, "position:x", 80, time_sec)

	tween.parallel().tween_property(animated_npc, "position:x", 300, time_sec)
	
