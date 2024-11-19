extends TextureRect

var current_stroke:PackedVector2Array #Array of points for current stroke
var all_strokes:Array[PackedVector2Array] #Array of strokes

@export var line_width:float = 3
@export var anti_alias:bool = true

func _draw():
	if not current_stroke.size() < 2:
		# Halts function if there are less than two points
		# As draw_polyline will fail
		draw_polyline(current_stroke,Color.AQUA,line_width,anti_alias)
		
	for stroke in all_strokes:
		# Draws previously made strokes
		draw_polyline(stroke,Color.ALICE_BLUE,line_width,anti_alias)

func _input(event):
	if Input.is_action_pressed("Draw"):
		# Adds current position to the current stroke
		current_stroke.append(event.position)
	elif Input.is_action_just_released("Draw"):
		# Adds current stroke to the list of all strokes and 
		# Empties the current stroke for another stroke
		all_strokes.append(current_stroke.duplicate())
		current_stroke.clear()
	if Input.is_action_pressed("Empty Drawing"):
		# Clears the whole drawing.
		current_stroke.clear()
	queue_redraw()
