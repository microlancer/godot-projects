extends PanelContainer

var DrawPanelContainer = preload("res://library/draw_panel_container.gd")

# From https://drtwelele.itch.io/casual-game-fx-one-shot
var fx_incorrect: AudioStream = preload("res://sound_fx/wind down 1.wav")
var fx_correct: AudioStream = preload("res://sound_fx/wind up 1.wav")



@onready var audio_player: AudioStreamPlayer2D = %AudioStreamPlayer2D  # Adjust the path if necessary

var draw_panel_container: PanelContainer
var kanji_characters = {
	"十": {
		"reading": "とお・じゅう",
		"strokes": [["R"], ["D"]]
	},
	"口": {
		"reading": "くち",
		"strokes": [["DR", "D"],["DR","R"],["R"]]
	},
	"言": {
		"reading": "いう・こと",
		"strokes": [["R","DR", "D"],["R"],["R"],["R"],"口"]
	},
	"刀": {
		"reading": "かたな",
		"strokes": [["DR"],["DL","D"]]
	},
	"刃": {
		"reading": "みと",
		"strokes": ["刀",["DR","D","R"]]
	},
	"心": {
		"reading": "みと",
		"strokes": [["DL","D"],["DR","D"],["DR","D"], ["DR","D"]]
	},
	"認": {
		"reading": "みと",
		"strokes": ["言","刃","心"]
	}
}

var kanji_keys
var kanji_to_draw

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$"../ResultLabel".text = ""
	$"../TryAgainButton".hide()
	
	#expand_strokes()
	
	kanji_keys= kanji_characters.keys()
	
	draw_panel_container = DrawPanelContainer.new()
	draw_panel_container.connect("stroke_drawn", Callable(self, "_on_stroke_drawn"))

	add_child(draw_panel_container)
	
	pick_random_kanji()

func expand_strokes(kanji):
	
	var done = false
	var i = 0
	var expansion = false
	while not done:
		
		var stroke = kanji.strokes[i]
		if stroke is String:
			expansion = true
			print("Convert " + stroke)
			var reference_strokes = kanji_characters[stroke].strokes
			kanji.strokes.remove_at(i) # remove the reference kanji
			for j in range(reference_strokes.size()-1, -1, -1):
				kanji.strokes.insert(i, reference_strokes[j])
			print(kanji.strokes)
			i = 0 # start over to search for recursive expansions
		else:
			i = i + 1
			
		if i >= kanji.strokes.size():
			done = true
	
func pick_random_kanji():
	var kanji_key = kanji_keys[randi() % kanji_keys.size()]
	kanji_to_draw = kanji_characters[kanji_key]
	expand_strokes(kanji_to_draw)
	$"../KanjiLabel".text = "[center]" + kanji_key + "[/center]"

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _on_stroke_drawn(strokeNumber, direction):
	
	print([strokeNumber, direction, kanji_to_draw.strokes])
	
	if direction in kanji_to_draw.strokes[strokeNumber]:
		print("correct")
	else:
		$"../ResultLabel".text = "[center][color=red]Incorrect[/color][/center]"
		$"../TryAgainButton".show()
		audio_player.stream = fx_incorrect
		audio_player.play()
		print("end")
		draw_panel_container.disable()
		return
		
	if strokeNumber == kanji_to_draw.strokes.size()-1:
		$"../ResultLabel".text = "[center][color=green]Correct![/color][/center]"
		print("end")
		audio_player.stream = fx_correct
		audio_player.play()
		draw_panel_container.disable()
		await clear_success_after_delay(1.5)
		draw_panel_container.clear()
		draw_panel_container.enable()
		
func clear_success_after_delay(delay: float):
	
	# Create a one-shot timer to wait for 1.5 seconds
	var timer = Timer.new()
	timer.wait_time = delay
	timer.one_shot = true
	add_child(timer)  # Add timer to the scene tree
	timer.start()

	# Wait for the timer to time out
	await timer.timeout

	# Clear the text of the label
	$"../ResultLabel".text = ""
	pick_random_kanji()
	
	# Optionally, remove the timer after use
	timer.queue_free()

func _on_clear_button_button_down() -> void:
	draw_panel_container.clear()
	
func _on_try_again_button_button_down() -> void:
	$"../ResultLabel".text = ""
	$"../TryAgainButton".hide()
	draw_panel_container.clear()
	draw_panel_container.enable()
	
