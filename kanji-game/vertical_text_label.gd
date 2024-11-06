extends Label



var actual_text: String = ""
var furigana = ""
var block_index = 0
var block_size = Vector2i(20, 13)
var block_margin = Vector2i(0, 0)
var block_normal_font_size = 12
var block_label_settings: LabelSettings
var block_furigana_offset = Vector2i(13, -5)
var block_furigana_font_size = 5
var block_furigana_line_spacing = -2
var block_furigana_width = 12
var block_grid = Vector2i(8, 8)

#var replace_index

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	
	pass
	
	#block_label_settings = LabelSettings.new()
	#block_label_settings.font_size = block_normal_font_size
	#self.text = ""
	#actual_text = "指指で・十・まで数えてください。"
	#furigana = ["ゆび","じゅう","かぞ"]
	#
	#var replace_types = [Main.REPLACE_TYPE_HIRAGANA, Main.REPLACE_TYPE_KANJI]
	#$Main.replacement_type = $Main.replace_types.pick_random()
	#
	#convert_text_to_blocks($Main.replacement_type)
	
func build_sentence(sentence_obj, replacement_type: String, done_chars: int = 0):
	
	for child in get_children():
		child.queue_free()
	
	block_label_settings = LabelSettings.new()
	block_label_settings.font_size = block_normal_font_size
	self.text = ""
	#actual_text = "指で・十・まで数えてください。"
	#furigana = ["ゆび","じゅう","かぞ"]
	
	actual_text = sentence_obj.sentence
	furigana = sentence_obj.furigana
	
	convert_text_to_blocks(replacement_type, false, done_chars)
	
func show_answer():
	for child in get_children():
		child.queue_free()
		
	# replacement type doesn't matter if we're going to show the answer
	convert_text_to_blocks(Globals.REPLACE_TYPE_HIRAGANA, true)
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func convert_text_to_blocks(replacement_type: String, show_answer: bool = false, done_chars: int = 0):
	
	var blocks = []
	var letter_index = 0
	var furigana_index = 0
	
	block_index = 0
	
	var actual_text_array = actual_text.split()
	var kana_array = Globals.KANA_REGULAR.split()
	var kana_small_array = Globals.KANA_SMALL.split()
	var other_array = Globals.KANA_SYMBOLS.split()
	
	var kanji_replacement_word_started = false
	var kanji_replacement_word_index = 0
	var kanji_word_started = false
	var kanji_word_length: int = 0
	
	for letter in actual_text:
		print({"furigana_index":furigana_index})
		var block: Label = Label.new()
		
		var is_kanji = letter not in kana_array and \
			letter not in kana_small_array and \
			letter not in other_array
			
		print("letter: " + letter)
		print({"letter":letter,"is_kanji":is_kanji})
		#print("block_index: " + str(block_index))
		#print("letter_index: " + str(letter_index))
		var previous_is_kanji = letter_index >= 1 and \
			actual_text_array[letter_index-1] not in kana_array and \
			actual_text_array[letter_index-1] not in kana_small_array and \
			actual_text_array[letter_index-1] not in other_array
			
		if is_kanji and (letter_index == 0 or not previous_is_kanji):
			#print({"letter":letter,"previous_is_kanji":previous_is_kanji})
			kanji_word_started = true
			kanji_word_length = 0
			# look ahead to see how many kanji characters the word is
			var i = 1
			var no_more_kanji = false
			while i < actual_text.length() - letter_index and not no_more_kanji:
				var ahead_is_kanji = actual_text_array[letter_index+i] not in kana_array and \
					actual_text_array[letter_index+i] not in kana_small_array and \
					actual_text_array[letter_index+i] not in other_array
				if not ahead_is_kanji:
					#print(actual_text_array[letter_index+i]+"...not kanji")
					no_more_kanji = true
				else: 
					#print(actual_text_array[letter_index+i]+"...more kanji")
					i += 1
			#print("total i: " + str(i))
			kanji_word_length = i
			# look ahead to see where the next end-of-line would be
			var chars_to_end_of_line = block_grid.y - floori(block_index % roundi(block_grid.y))
			#print("chars to end of line: " + str(chars_to_end_of_line))
			
			if chars_to_end_of_line < kanji_word_length:
				#print("not enough space to put full kanji word")
				block_index += floori(chars_to_end_of_line)
			else:
				#print("enough space")
				pass
		
		#print({"kanji_word_started":kanji_word_started})
		
		block.text = letter
		block.label_settings = block_label_settings
		block.position.y = (block_index % roundi(block_grid.y)) * \
			block_size.y + block_margin.y
		
		# We will center the x position based on number of columns
		var total_columns = floori(actual_text.length() / float(block_grid.y))
		var centering_offset = 0.5 * self.size.x #+ 
		var columns_width_offset = 0.5 * total_columns * block_size.x
		
		block.position.x = self.position.x + self.size.x - \
			 ((1 + (floor(block_index / roundi(block_grid.y)))) * block_size.x) \
			 - centering_offset \
			 + columns_width_offset
			
	
		print({
			"total_columns":total_columns,
			"centering_offset":centering_offset,
			"columns_width_offset":columns_width_offset,
			"block.position.x":block.position.x
		})
		
		if letter == "。":
			block.rotation_degrees = 270
			block.position.x -= 4
			block.position.y += 8
			
		if letter == "ー":
			block.rotation_degrees = 270
			block.position.x -= 4
			block.position.y += 16
		
		if letter == "・":
			kanji_replacement_word_started = !kanji_replacement_word_started
			letter_index += 1
			#print("continue")
			continue
			
		if letter == "｜":
			block_index -= 1
			
		if letter in Globals.KANA_SMALL:
			block.position.x += 2
		
		if letter != "｜":
			self.add_child(block)
		
		#print({"kanji_word_started":kanji_word_started})
		
		if is_kanji and kanji_replacement_word_started:
			
			if !show_answer and \
				replacement_type == Globals.REPLACE_TYPE_KANJI and \
				kanji_replacement_word_started and \
				kanji_replacement_word_index >= done_chars:
				# enter the kanji
				#print("not showing the kanji since it's > than done_chars")
				#print({"letter_index":letter_index,"kanji_replacement_word_index":kanji_replacement_word_index,"done_chars":done_chars})
				block.text = ""
			#elif !show_answer and kanji_replacement_word_started and \
					#replacement_type == Globals.REPLACE_TYPE_KANJI and \
					#letter_index >= done_chars:
					#print("not showing the kanji since it's > than done_chars")
					#block.text = ""
			
			var underline_block = block.duplicate()
			underline_block.text = "＿"
			underline_block.rotation_degrees = -90
			underline_block.position.x -= 3
			underline_block.position.y += block.size.y - 2
			#if !show_answer:
			self.add_child(underline_block)
		
		#print({
			#"total_columns": total_columns, 
			#"pos": block.position, 
			#"centering_offset": centering_offset,
			#"columns_width_offset": columns_width_offset
		#})
		
		var ahead_is_kanji = letter_index + 1 < actual_text_array.size() and \
			actual_text_array[letter_index+1] not in kana_array and \
			actual_text_array[letter_index+1] not in kana_small_array and \
			actual_text_array[letter_index+1] not in other_array
					
					
		print({"kanji_word_started":kanji_word_started,"ahead_is_kanji":ahead_is_kanji})
		if kanji_word_started and not ahead_is_kanji:
			kanji_word_started = false
			print("end of kanji word, create furigana")
			print(furigana, furigana_index)
			# create furigana label
			var furigana_label = Label.new()
			
			if !show_answer and kanji_replacement_word_started and \
				replacement_type == Globals.REPLACE_TYPE_HIRAGANA and \
				done_chars == 0:
				furigana_label.hide()
			
			furigana_label.autowrap_mode = TextServer.AUTOWRAP_ARBITRARY
			furigana_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
			furigana_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
			furigana_label.label_settings = LabelSettings.new()
			furigana_label.label_settings.font_size = block_furigana_font_size
			furigana_label.label_settings.line_spacing = block_furigana_line_spacing
			furigana_label.clip_text = true
			#furigana_label.clip_contents = true
			#furigana_label.clip_children = true
			furigana_label.custom_minimum_size = Vector2(1,1)
			
			var furigana_panel = Control.new()
			
			var label_with_newlines = ""
			var f = 0
			
			for furigana_letter in furigana[furigana_index]:
				#print(furigana_letter)
				label_with_newlines += furigana_letter
				f += 1
				#print("done_chars: " + str(done_chars))
				if !show_answer and kanji_replacement_word_started and \
					replacement_type == Globals.REPLACE_TYPE_HIRAGANA and \
					f >= done_chars:
					break
				if f < furigana[furigana_index].length():
					label_with_newlines += "\n"
				
			#print(label_with_newlines)
			furigana_label.text = furigana[furigana_index]
			furigana_label.text = label_with_newlines
			
			furigana_panel.position.x = block.position.x + block_furigana_offset.x
			
			var first_y = (block_index - (kanji_word_length-1)  % roundi(block_grid.y)) * \
				block_size.y + block_margin.y
				
			var general_block_y = ((block_index+2 - kanji_word_length - 1) % roundi(block_grid.y)) * \
				block_size.y + block_margin.y
				
			first_y = block.position.y
			first_y = general_block_y
			furigana_panel.position.y = first_y
			furigana_panel.size.x = block_furigana_width
			furigana_panel.size.y = ((block.size.y - 6) * kanji_word_length) + 9# - (kanji_word_length * 3)
			#print({"panel":furigana_panel.size})
			furigana_label.size.y = furigana_panel.size.y
			furigana_label.size.x = furigana_panel.size.x
			#print({"label":furigana_label.size})
			
			if kanji_word_length == 1 and furigana[furigana_index].length() > 3:
				furigana_label.label_settings.font_size -= 2
			
			furigana_index += 1
			
			var style_box_empty = StyleBoxEmpty.new()
			furigana_panel.set("custom_styles/panel", style_box_empty)
			
			self.add_child(furigana_panel)
			furigana_panel.add_child(furigana_label)
		
		if kanji_replacement_word_started:
			kanji_replacement_word_index += 1
					
		
		block_index += 1
		#print(letter)
		
		letter_index += 1
