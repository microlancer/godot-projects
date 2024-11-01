extends Panel

var DrawPanel = preload("res://library/draw_panel.gd")


var draw_panel: Panel

#var kanji_characters = {}
#var kanji_keys
var kanji_to_draw
var replacement_type

@export var kanji_refs = {}


signal correct_stroke(strokeIndex, direction)
signal kanji_correct()
signal kanji_incorrect()

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	#$"../ResultLabel".text = ""
	#$"../TryAgainButton".hide()
	
	#expand_strokes()
	
	#kanji_keys = kanji_characters.keys()
	
	draw_panel = DrawPanel.new()
	draw_panel.connect("stroke_drawn", Callable(self, "_on_stroke_drawn"))

	add_child(draw_panel)
	draw_panel.size = self.size
	
func set_kanji_to_expect(kanji: String):
	print("Setting kanji to expect: " + kanji)
	kanji_to_draw = kanji_refs[kanji]
	#print(kanji_to_draw)
	draw_panel.clear()
	expand_strokes(kanji_to_draw)

func expand_strokes(ref_kanji):
	
	print("expand_strokes")
	var done = false
	var i = 0
	var expansion = false
	while not done:
		
		var stroke = ref_kanji.strokes[i]
		if stroke is String:
			expansion = true
			print("Convert " + stroke)
			var reference_strokes = kanji_refs[stroke].strokes
			ref_kanji.strokes.remove_at(i) # remove the reference kanji
			for j in range(reference_strokes.size()-1, -1, -1):
				ref_kanji.strokes.insert(i, reference_strokes[j])
			print({"kanji.strokes":ref_kanji.strokes})
			i = 0 # start over to search for recursive expansions
		else:
			i = i + 1
			
		if i >= ref_kanji.strokes.size():
			done = true
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _on_stroke_drawn(stroke_index, direction):
	
	print([stroke_index, direction, kanji_to_draw.strokes])
	
	if direction not in kanji_to_draw.strokes[stroke_index]:
		kanji_incorrect.emit()
		#$"../ResultLabel".text = "[center][color=red]Incorrect[/color][/center]"
		#$"../TryAgainButton".show()
		
		draw_panel.disable()
		return
	#print(kanji_to_draw)
	var size_valid = not kanji_to_draw.has("small") or \
		(kanji_to_draw.small and $"../KomojiButton".button_pressed) \
		or (not kanji_to_draw.small and not $"../KomojiButton".button_pressed)
	
	#print({"size valid?":size_valid})
	if stroke_index == kanji_to_draw.strokes.size()-1:
		#$"../ResultLabel".text = "[center][color=green]Correct![/color][/center]"
		
		if not size_valid:
			kanji_incorrect.emit()
			draw_panel.disable()
		else:
			$"../KomojiButton".button_pressed = false # reset
			kanji_correct.emit()
		
		#draw_panel.disable()
		#await clear_success_after_delay(1)
		#draw_panel.clear()
		#draw_panel.enable()
	else:	
		# single correct stroke, kanji not yet finished
		correct_stroke.emit(stroke_index, direction)
		
func xxxclear_success_after_delay(delay: float):
	
	# Create a one-shot timer to wait for 1.5 seconds
	var timer = Timer.new()
	timer.wait_time = delay
	timer.one_shot = true
	add_child(timer)  # Add timer to the scene tree
	timer.start()

	# Wait for the timer to time out
	await timer.timeout

	# Clear the text of the label
	#$"../ResultLabel".text = ""
	#pick_random_sentence()
	
	# Optionally, remove the timer after use
	timer.queue_free()

func _on_clear_button_button_down() -> void:
	draw_panel.clear()
	
func reset_draw_panel():
	draw_panel.brush_color = Color.WHITE_SMOKE
	draw_panel.clear()
	draw_panel.enable()
	
func _on_try_again_button_button_down() -> void:
	$"../ResultLabel".text = ""
	$"../TryAgainButton".hide()
	draw_panel.clear()
	draw_panel.enable()

func redraw_with_color(color):
	draw_panel.brush_color = color
	draw_panel.queue_redraw()
