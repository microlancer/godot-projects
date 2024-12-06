extends Node2D

var tick_boxes: Array = []
var frame_index: int = 0
var TickBox: PackedScene = preload("res://tick_box.tscn")
# Called when the node enters the scene tree for the first time.

var sequence = "D,DR,R,HP"
var frames_per_button = 60
var current_waiting_button = 0
var started_capture = false
var timing = []
	
var tick_box_colors: Array = [
	Color.WHITE,
	Color.RED,
	Color.BLUE,
	Color.GREEN,
	Color.PURPLE,
	Color.YELLOW,
	Color.ORANGE,
	Color.LIGHT_BLUE,
]
var color_index = 1
var tick_box_color = Color.BLACK

func _ready() -> void:
	var col = 0
	var row = 0
	for i in range(0,900):
		var tick_box: Polygon2D = TickBox.instantiate()
		tick_box.color = tick_box_color
		var x = col * 18
		var y = row * 18
		var margin_left = 20
		var margin_top = 300
		tick_box.position = Vector2(margin_left + x, margin_top + y)
		tick_boxes.push_back(tick_box)
		col += 1
		if col >= 60:
			col = 0
			row += 1
		add_child(tick_box)
		
	
		
	create_frame_windows_for_motion()
	
	%ExpectedButton.text = timing[0].button
	
		
func create_frame_windows_for_motion():
	
	frames_per_button = int(%ButtonFrames.text)
	
	var buttons = sequence.split(",")

	timing = []
	
	var begin_frame = 0
	
	for i in buttons.size():
		
		var mapped_code
		
		if buttons[i] == "D":
			mapped_code = 83
		elif buttons[i] == "DR":
			mapped_code = 68
		elif buttons[i] == "R":
			mapped_code = 70
		elif buttons[i] == "HP":
			mapped_code = 71
		else:
			mapped_code = 0
			
		var end_frame = begin_frame + frames_per_button
			
		var expect = {
			"button": buttons[i],
			"mapped_code": mapped_code,
			"begin_frame": begin_frame,
			"end_frame": end_frame,
		}
		
		begin_frame += frames_per_button
		
		timing.push_back(expect)
		
	print(timing)
		
func _unhandled_key_input(event):
	print(event)
	if !event.is_pressed():
		if !started_capture and event.keycode == timing[0].mapped_code:
			print("pressed button")
			clear()
			%Info.text = "Press da buttons!"
			# reset timing windows in case the UI value chaged
			create_frame_windows_for_motion()
			started_capture = true
			tick_boxes[frame_index % 900].color = Color.WHITE
			current_waiting_button += 1
			%ExpectedButton.text = timing[current_waiting_button].button
		elif started_capture:
			if event.keycode != timing[current_waiting_button].mapped_code:
				# pressed wrong button
				%Info.text = "Pressed wrong button in sequence, wanted: " + timing[current_waiting_button].button	
				restart()
			elif event.keycode == timing[current_waiting_button].mapped_code && \
				frame_index < timing[current_waiting_button].begin_frame:
				# pressed button too early
				%Info.text = "Pressed " + timing[current_waiting_button].button + " button too early by " + str(timing[current_waiting_button].begin_frame - frame_index) + " frames" 
				restart()
			elif event.keycode == timing[current_waiting_button].mapped_code && \
				frame_index > timing[current_waiting_button].end_frame:
				# pressed button too late
				%Info.text = "Pressed " + timing[current_waiting_button].button + " button too late by " + str(frame_index - timing[current_waiting_button].end_frame) + " frames" 
				restart()
			else: 
				# pressed right button
				current_waiting_button += 1
				tick_boxes[frame_index-1 % 900].color = Color.WHITE
				if current_waiting_button >= timing.size():
					# completed full sequence
					%Info.text = "Well done!"
					restart()
				else: 
					# next button
					%ExpectedButton.text = timing[current_waiting_button].button
			
		print(event)

func restart():
	started_capture = false
	frame_index = 0
	current_waiting_button = 0
	%ExpectedButton.text = timing[0].button
	
func clear():
	for i in range(0,900):
		tick_boxes[i].color = Color.BLACK
	color_index = 1
	
	
# Called every frame. 'delta' is the elaspsed time since the previous frame.
func _process(_delta: float) -> void:
	
	if started_capture:
		if frame_index % frames_per_button == 0:
			tick_box_color = tick_box_colors[color_index % tick_box_colors.size()]
			print("New color", tick_box_color)
			color_index += 1
			
		if frame_index % 900 != 0:
			tick_boxes[frame_index % 900].color = tick_box_color
		%CurrentFrameNum.text = str(frame_index % 900) + "/900"
		frame_index += 1
		
		# check if the next button is pressed within the window
		
	
