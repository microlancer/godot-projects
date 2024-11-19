extends TextureRect

var array_of_points:PackedVector2Array #Array of points for current stroke
var array_of_strokes:Array[PackedVector2Array] #Array of strokes

func _draw():
	if not array_of_points.size() < 2:
		# Halts function if there are less than two points
		# As draw_polyline will fail
		draw_polyline(array_of_points,Color.AQUA,10)
		
	for stroke in array_of_strokes:
		draw_polyline(stroke,Color.ALICE_BLUE,10)

func _input(event):
	if Input.is_action_pressed("Draw"):
		array_of_points.append(event.position)
	elif Input.is_action_just_released("Draw"):
		array_of_strokes.append(array_of_points.duplicate())
		array_of_points.clear()
	if Input.is_action_pressed("Empty Drawing"):
		array_of_points.clear()
	queue_redraw()
