extends Control

# DrawPanel is a Panel that allows for drawing (with mouse
# or touch) and originally designed for detecting when kanji characters are 
# written. For each stroke, a stroke_drawn signal is emitted.
# When the event is fired, it will also pass along the directional type of 
# stroke as follows:
#   DR = Down Right      DL = Down Left     UR = Up Right     UL = Up Left
#   DD = Down (Straight)                    UU = Up (Straight)
#   RD = Right Down      RU = Right Up      LD = Left Down    LU = Left Up
#   RR = Right (Straight)                   LL = Left (Straight)
#
# For angled strokes (DR,DL,UR,UL,RD,RU,LD,LU) the determining factor is that
# The length of the second stroke is beyond half of the first stroke. In some
# cases, this is too tight, so it's better to use D*, U*, R*, L* in these
# sitations which will allow for detecting any of them as success.
#
# Some strokes like the dot can be finicky, so a ** stroke meaning anything
# can be useful.

var prev_point = Vector2.ZERO

var stroke_index = 0
var strokes = [[]]
var alreadyDrawnIndex = -1
var antialiasing = false
@export var brush_color = Color.WHITE_SMOKE #Color.GOLDENROD
var brush_width = 1
var minimum_point_distance = 1
var enabled = true
	
signal stroke_drawn(stroke_index, direction)
signal stroke_started()

func _ready():	
	Input.set_use_accumulated_input(false)
	pass
	
func end_stroke():
	if strokes[stroke_index].size() == 0:
		# Skip this function if there's no stroke in progress.
		return
	queue_redraw()
	var stroke = calculate_stroke(strokes[stroke_index])
	#print(direction)
	#print("emiting stroke_index=" + str(stroke_index))
	stroke_drawn.emit(stroke_index, stroke)
	# start a new stroke
	#print("starting a new stroke: " + str(stroke_index))
	
	# check this again after emit, since emit can reset the strokes
	if strokes[stroke_index].size() == 0:
		# Skip this function if there's no stroke in progress.
		#print("no stroke in progress")
		return
	
	stroke_index += 1
	strokes.append([])
	
func _gui_input(event):
	
	if !enabled:
		#print("disabled")
		return
		
	if event is InputEventMouseButton:
		if !event.is_pressed() or !event.button_index == MOUSE_BUTTON_LEFT:
			if strokes[stroke_index].size() > 0:
				end_stroke()
			return
	
	# Handle mouse motion for drawing strokes
	if event is InputEventMouseMotion:
		handle_mouse(event)
		
func handle_mouse(event):
	
	if is_out_of_bounds(event.position):
		# skip events happening outside of the drawing area
		#print("out of bounds")
		end_stroke()
		return
				
	if not Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		if (strokes[stroke_index].size() > 0):
			#print("event="+event.as_text())
			end_stroke()
		#_circle_pos = []
		return
	
	# skip points too close to each other
	if strokes[stroke_index].size() > 1:
		#print(event.position)
		#print(strokes[strokeIndex][-1])
		var distance = event.position.distance_to(strokes[stroke_index][-1])
		if distance < minimum_point_distance:
			#print('skip')
			return
	
	if strokes[stroke_index].size() == 0:
		stroke_started.emit()
		
	strokes[stroke_index].append(event.position)
	
	
	queue_redraw()
	
func is_out_of_bounds(point):
	var margin = 0
	var out_of_bounds = point.x < margin or point.y < margin \
		or point.x > self.size.x - margin or point.y > self.size.y - margin		
	return out_of_bounds
	
func _draw():	
	
	for loopStrokeIndex in range(strokes.size()):
		
		var stroke = strokes[loopStrokeIndex]
		
		if stroke.size() <= 1:
			continue;
		
		#print([loopStrokeIndex, alreadyDrawnIndex])
		if false and loopStrokeIndex <= alreadyDrawnIndex:
			continue
		
		for point_index in range(stroke.size()):
			var point = stroke[point_index]
			if is_out_of_bounds(point):
				continue;
			if point_index == 0:
				draw_circle(point, brush_width - 1, brush_color)
			elif point_index == stroke.size()-1:
				draw_line(prev_point, point, brush_color, brush_width, antialiasing)
				draw_circle(point, brush_width - 1, brush_color)
			else:
				draw_line(prev_point, point, brush_color, brush_width, antialiasing)
			prev_point = point
			
	alreadyDrawnIndex = strokes.size() - 2
			
	return
	
func count_direction_changes(points):
	if points.size() < 3:
		return 0

	var changes = 0
	for i in range(1, points.size() - 1):
		var dx1 = points[i].x - points[i - 1].x
		var dx2 = points[i + 1].x - points[i].x
		var dy1 = points[i].y - points[i - 1].y
		var dy2 = points[i + 1].y - points[i].y
		
		# Check if there's a reversal in x or y direction
		if sign(dx1) != sign(dx2) and abs(dx1) > 5 and abs(dx2) > 5:
			changes += 1
		if sign(dy1) != sign(dy2) and abs(dy1) > 5 and abs(dy2) > 5:
			changes += 1

	return changes
	
func count_major_direction_changes(points, num_segments=5):
	if points.size() < num_segments + 1:
		return 0

	# Step 1: Divide points into segments
	var segment_size = int(points.size() / num_segments)
	var directions = []
	
	# Step 2: Calculate average direction per segment
	for i in range(num_segments):
		var start = points[i * segment_size]
		var end = points[min((i + 1) * segment_size, points.size() - 1)]
		
		var dx = end.x - start.x
		var dy = end.y - start.y
		
		# Determine direction for this segment
		if abs(dx) > abs(dy):  # Horizontal movement dominates
			directions.append("R" if dx > 0 else "L")
		else:  # Vertical movement dominates
			directions.append("D" if dy > 0 else "U")
	
	# Step 3: Count directional changes between segments
	var direction_changes = 0
	for i in range(1, directions.size()):
		if directions[i] != directions[i - 1]:
			direction_changes += 1

	return direction_changes
		
func is_curved(points):
	if points.size() < 3:
		return false

	var start_point = points[0]
	var end_point = points[-1]
	var threshold = max(abs(end_point.x - start_point.x), abs(end_point.y - start_point.y)) * 0.1
	var curved_points = 0

	for i in range(1, points.size() - 1):
		var point = points[i]
		# Calculate perpendicular distance to the line (start_point -> end_point)
		var distance = abs((end_point.y - start_point.y) * point.x - (end_point.x - start_point.x) * point.y + end_point.x * start_point.y - end_point.y * start_point.x) / sqrt(pow(end_point.y - start_point.y, 2) + pow(end_point.x - start_point.x, 2))
		if distance > threshold:
			curved_points += 1
	
	# If a significant portion of points deviate, consider it curved
	return curved_points > points.size() * 0.3
	
# Every collection of points can be converted into one of the following 
# vector strokes.
# down (A), right (B), down-left (C), down-right (D),
# right-down corner (E), down-right corner (F)
# We calculate the bounding box based on the longest X or Y distance
# between any two vectors.
func calculate_stroke(points):
	
	if points.size() == 0:
		return
		
	var total_x = abs(points[-1].x - points[0].x)
	var total_y = abs(points[-1].y - points[0].y)
	var max_size = max(total_x, total_y)
	var half_size = int(max_size / 2)
	
	var direction_data = {
		"direction": "", 
		"is_corner": true, 
		"is_curved": false, 
		"direction_changes": 0
	}
	
	#print([total_x, total_y, max_size, half_size])
	
	var moved_more_than_half_right = points[-1].x - points[0].x > half_size
	var moved_more_than_half_left = points[0].x - points[-1].x > half_size
	var moved_more_than_half_down = points[-1].y - points[0].y > half_size
	var moved_more_than_half_up = points[0].y - points[-1].y > half_size
	
	if moved_more_than_half_right and moved_more_than_half_down:
		direction_data["direction"]  = "DR"
	elif moved_more_than_half_left and moved_more_than_half_down:
		direction_data["direction"]  = "DL"
	elif moved_more_than_half_right and moved_more_than_half_up:
		direction_data["direction"]  = "UR"
	elif moved_more_than_half_left and moved_more_than_half_up:
		direction_data["direction"]  = "UL"
	elif moved_more_than_half_right:
		direction_data["direction"]  = "R"
	elif moved_more_than_half_left:
		direction_data["direction"]  = "L"
	elif moved_more_than_half_down:
		direction_data["direction"]  = "D"
	else:
		direction_data["direction"]  = "U"
		
	var is_corner = true
	
	# Additional characteristics
	direction_data["is_curved"] = is_curved(points)
	direction_data["direction_changes"] = count_major_direction_changes(points)
	
	
	print("corner - check width of box", self.size)
	var small_box_x = self.size.x / 2
	var small_box_y = self.size.y / 2
	
	for p in points:
		if p.x < small_box_x or p.y < small_box_y:
			direction_data["is_corner"] = false
			break
			
	print(direction_data)
	return direction_data
	
func _on_mouse_exited() -> void:
	# If the user swipes beyond the drawing area, just end the stroke.
	#print("exit")
	end_stroke()
	
func clear():
	#print("clearing stroke index")
	stroke_index = 0
	strokes = [[]]
	alreadyDrawnIndex = -1	
	queue_redraw()

# this is just an example of how to clear the draw panel
func _on_button_button_down() -> void:
	clear()
	
func disable():
	enabled = false
	
func enable():
	enabled = true
