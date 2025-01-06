extends Node2D
class_name Main

var attacks = ["attack_up", "attack_down", "attack_spin"]
var is_battle_start = true
var kanji_sentences = []
#var kanji_refs = {}
var current_draw_character_index = 0
var current_draw_total_characters = 0
var replacement_type
var sentence_obj
var draw_word
var level_up_during_battle = false
var translation_mode = "Jp"
#@export var replacement_type = Globals.REPLACE_TYPE_HIRAGANA

@onready var audio_player: AudioStreamPlayer2D = %AudioStreamPlayer2D  # Adjust the path if necessary
@onready var audio_player2: AudioStreamPlayer2D = %AudioStreamPlayer2D2  # Adjust the path if necessary

var default_damage_label_y = 0
var default_damage_label_color

var player_hp_max = 5
var player_hp = 5
var enemy_hp_min = 5
var enemy_hp_max = 5
var enemy_hp = 8
var enemy_level_max = 1
var enemy_hp_range_min = 8
var enemy_hp_range_max = 8

var player_exp = 0
var player_gold = 0
var potential_exp = 0

var player_dmg_min = 1
var player_dmg_max = 3

var enemy_dmg_min = 1
var enemy_dmg_max = 3

var player_level = 1
var enemy_level = 1
var enemy_name = "スケルトン"
var player_name = "PlayerXXX"
var player_kp = 0 # kanji points
var player_bp = 0 # battle points

var complete_pool = []
var known_pool_index = 0

var target_word: String = ""
var mastery_max = 99

# These parameters are tweaked during debugging
# To debug, change debug_detector_mode = true
#           change debug_detector_kanji = "<charyouwant>"
# -------------------------------------------------------------------
# -------------------------------------------------------------------
var skilled_threshold = 3 # correct answers to no hints (3)
var mastery_threshold = 6 # correct answers to next kanji (6)
var start_fresh = 0
var init_progress =  {"一":{"r":0,"w":0}}
var progress = init_progress
var debug_detector_mode: bool = false
var debug_detector_kanji: String = "慢"
var active_item: InventoryItem = null
@export var world: World
@onready var animated_player: Player = world.Player
@onready var LevelManager = $LevelContainer
var current_level: BaseLevel = null
var animated_enemy:AnimatedSprite2D = null
@onready var enemy_damage_label:Label = world.Player_health_label
@onready var player_damage_label:Label = world.Enemy_health_label
@onready var Health_bar_player:ProgressBar = world.player_health_bar
@onready var Health_bar_enemy:ProgressBar = world.enemy_health_bar
@export var level_up_button:Button

# -------------------------------------------------------------------
# -------------------------------------------------------------------

	
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	current_level = LevelManager.load_level(Globals.lvl_to_load)
	$CanvasLayer/LevelLabel.text = "Current level: " + str(Globals.lvl_to_load)
	print(current_level)
	animated_enemy = world.spawn_enemy(current_level.enemies)
	
	$UI.hide()
	$UI2.hide()
	
	world.connect("end_run_to_npc", Callable(self, "_end_run"))
	animated_player.connect("animation_changed", Callable(self, "_animation_changed"))
	animated_player.used_item.connect(_on_player_used_item)
	animated_player.holding_items = Globals.player_inven 
	animated_player.update_inventory_ui()
	
	animated_player.connect("animation_finished", Callable(self, "_animation_finished"))
	animated_player.connect("animation_looped", Callable(self, "_animation_looped_player"))
	animated_enemy.connect("animation_finished", Callable(self, "_animation_finished_enemy"))
	get_tree().get_root().size_changed.connect(Callable(self, "_on_size_changed"))
	if not start_fresh:
		load_game()
	
	default_damage_label_y = enemy_damage_label.position.y
	default_damage_label_color = enemy_damage_label.modulate
	enemy_damage_label.hide()
	player_damage_label.hide()
	level_up_button.hide()
	
	enemy_hp_max = randi_range(enemy_hp_range_min, enemy_hp_range_max)
	enemy_hp = enemy_hp_max
	
	update_hp()
	
	# load kanji
	#var file_path = "res://data/kanji_data.json"
	#var json_as_text = FileAccess.get_file_as_string(file_path)
	#var kanji_data = JSON.parse_string(json_as_text)
	var kanji_data = current_level.load_kanji()
	kanji_sentences = kanji_data["sentences"]
	complete_pool = kanji_data["pool"]
	#kanji_refs = kanji_data.refs
	
	$UI/KanjiDrawPanel.kanji_refs = kanji_data["refs"]
	
	pick_random_sentence()
	save_game()
	
	$UI2/NextBattleButton.hide()
	#replacement_type = Globals.REPLACE_TYPES.pick_random()
	
	if debug_detector_mode:
		$UI/KanjiDrawPanel.debug = true
		$UI/KanjiDrawPanel.set_kanji_to_expect(debug_detector_kanji)
		%KanjiLabel.show()
		$UI2/DebugButton1.show()
	else:
		$UI2/DebugButton1.hide()
	
	$UI/KanjiDrawPanel.draw_panel.connect("stroke_started", Callable(self, "_on_stroke_started"))
	
func _on_player_used_item(item): 
	if item.item_name == "potion":
		item.applyEffect(self)
	if item.turns_left > 0: 
		active_item = item
		active_item.expired.connect(_on_item_expired)
		# currently only 1 item at a time
		
func _on_item_expired(): 
	active_item = null
	pass 

func _end_run() -> void:
	animated_player.animation = "idle"
	animated_player.play()
	
	animated_enemy.animation = "enemy_idle"
	animated_enemy.play()
	
	#animated_enemy2.animation = "snake_idle"
	#animated_enemy2.play()
	
	#$AudioStreamPlayerBgMusic.play()
	is_battle_start = true
	
	Globals.AudioStreamPlayerBgMusic.stream = Globals.music_action1
	Globals.AudioStreamPlayerBgMusic.play()
	
	$UI.show()
	$UI2.show()
	world.UI.show()
	
	#animated_player.animation = "idle"
	#animated_player.offset.y = 0
	#animated_player.play()
	
	#$AudioStreamPlayer2D.stop()
	#Health_bar_enemy.show()
	
	print("_encounter_enemy")
	
	start_battle()
	
func _on_stroke_started():
	print("_on_stroke_started")
	audio_player.stream = Globals.fx_light_torch1
	audio_player.play()
	
func load_game():
	var file_path_save = "user://save_game.json"
	var save_json_as_text = FileAccess.get_file_as_string(file_path_save)
	var save_data = JSON.parse_string(save_json_as_text)
	
	if not save_data or save_data.size() == 0 or not save_data.has("slot0"):
		# try to create it
		player_gold = 0
		player_level = 1
		set_stats_by_level(player_level)
		player_hp = player_hp_max # reset for new game
		known_pool_index = 1
		progress = init_progress
		save_game()
		load_game()
		return
	
	known_pool_index = save_data.slot0.known_pool_index
	player_kp = save_data.slot0.kp
	
	if not save_data.slot0.has("gold"):
		player_gold = 0
	else:
		player_gold = save_data.slot0.gold
		
	player_level = save_data.slot0.level
	
	if not save_data.slot0.has("hp"):
		player_hp = player_hp_max
	else:
		player_hp = save_data.slot0.hp
	
	set_stats_by_level(player_level)
	
	progress = save_data.slot0.progress
	print({"save_data":save_data})
	
func pick_random_based_on_value(options):
	var weights = []
	var total_weight = 0.0
	
	var zero_value_items = []
	for item in options:
		if item.value == 0:
			zero_value_items.append(item)

	# If there are any items with zero value, choose from them at random
	if zero_value_items.size() > 0:
		return zero_value_items[randi() % zero_value_items.size()]

	# Calculate inverse weight for each item
	for option in options:
		var weight = 1.0 / float(option["value"])
		weights.append(weight)
		total_weight += weight

	# Normalize weights to create cumulative probabilities
	var cumulative_probabilities = []
	var cumulative = 0.0
	for weight in weights:
		cumulative += weight / total_weight
		cumulative_probabilities.append(cumulative)

	# Pick a random number between 0 and 1
	var random_choice = randf()

	# Select item based on cumulative probabilities
	for i in range(options.size()):
		if random_choice < cumulative_probabilities[i]:
			return options[i]


	
func save_game():
	
	
	var file = FileAccess.open("user://save_game.json", FileAccess.WRITE)
	var save_data = {
		"slot0": {
			"name": Globals.player_name,
			"level": player_level,
			"hp": player_hp,
			"gold": player_gold,
			"kp": player_kp,
			"known_pool_index": known_pool_index,
			"progress": progress,
			"bg_music_enabled": Globals.custom_bg_music_enabled
		}
	}
	print({"save_data":save_data})
	file.store_string(JSON.stringify(save_data))
	
	
func pick_random_sentence():
	
	var items: Array = []
	
	for item_key in progress:
		items.push_back({
			"name": item_key,
			"replacement_type": Globals.REPLACE_TYPE_HIRAGANA,
			"value": int(progress[item_key].r)
		})
		items.push_back({
			"name": item_key,
			"replacement_type": Globals.REPLACE_TYPE_KANJI,
			"value": int(progress[item_key].w)
		})
		
	print({"items":items,"kanji_sentences":kanji_sentences})
	
	# Example usage
	var randomly_selected_option = pick_random_based_on_value(items)
	#var word: String = selected_option.split("+")[0]
	#replacement_type = selected_option.split("+")[1]
	
	print("Selected item:", randomly_selected_option)
	
	print("picking random sentence")
	#sentence_obj = kanji_sentences.pick_random()
	
	sentence_obj = kanji_sentences[randomly_selected_option.name]
	
	#replacement_type = Globals.REPLACE_TYPES.pick_random()
	replacement_type = randomly_selected_option.replacement_type
	
	print("replacement_type: " + str(replacement_type))
	current_draw_character_index = 0
	current_draw_total_characters = 0
		
	set_char_to_draw(sentence_obj, replacement_type)
	
	$UI/VerticalTextLabel.build_sentence(sentence_obj, replacement_type)
	
	#$"../KanjiLabel".text = "[center]" + kanji_key + "[/center]"
	#$"../SentenceLabel".text = "[center]" + sentence_obj.sentence + "[/center]"
	
func set_char_to_draw(sentence_obj, replacement_type):
	
	draw_word = get_draw_word(sentence_obj)
	target_word = "".join(draw_word)
	
	print({"progress":progress,"target_word":target_word})
	
	%KanjiLabel.show()
	
	if progress.has(target_word):
		if replacement_type == Globals.REPLACE_TYPE_HIRAGANA:
			if progress[target_word].has("r") and progress[target_word].r >= skilled_threshold:
				print("hiding")
				%KanjiLabel.hide()
		if replacement_type == Globals.REPLACE_TYPE_KANJI:
			if progress[target_word].has("w") and progress[target_word].w >= skilled_threshold:
				print("hiding")
				%KanjiLabel.hide()
	
	if replacement_type == Globals.REPLACE_TYPE_HIRAGANA:
		set_furigana_to_draw(sentence_obj)
	else:
		set_kanji_to_draw(sentence_obj)
		
func get_draw_word(sentence_obj):
	var sentence = sentence_obj.sentence.split()
	var start_word_search = false
	var draw_word = []
	var kana_array = Globals.KANA_REGULAR.split()
	var kana_small_array = Globals.KANA_SMALL.split()
	var other_array = Globals.KANA_SYMBOLS.split()
	# find kanji word that needs to be drawn
	for i in range(0, sentence.size()):
		var letter = sentence[i]
		if letter == "・":
			start_word_search = !start_word_search
			
		var letter_is_kanji = letter not in kana_array and \
			letter not in kana_small_array and \
			letter not in other_array
			
		if start_word_search and letter_is_kanji:
			draw_word.push_back(letter)
		print(letter)
		print(draw_word)	
		
	current_draw_total_characters = draw_word.size()	
	
	print({"draw_word":draw_word})
	
	return draw_word
	
	
func set_kanji_to_draw(sentence_obj):
	#var sentence = sentence_obj.sentence.split()
	#var start_word_search = false
	#var draw_word = []
	#var kana_array = Globals.KANA_REGULAR.split()
	#var kana_small_array = Globals.KANA_SMALL.split()
	#var other_array = Globals.KANA_SYMBOLS.split()
	## find kanji word that needs to be drawn
	#for i in range(0, sentence.size()):
		#var letter = sentence[i]
		#if letter == "・":
			#start_word_search = !start_word_search
			#
		#var letter_is_kanji = letter not in kana_array and \
			#letter not in kana_small_array and \
			#letter not in other_array
			#
		#if start_word_search and letter_is_kanji:
			#draw_word.push_back(letter)
		#print(letter)
		#print(draw_word)	
		
	current_draw_total_characters = draw_word.size()	
	
	print({"draw_word":draw_word})
	
	target_word = "".join(draw_word)
	
	var kanji_key = draw_word[current_draw_character_index]
	$UI/KanjiDrawPanel.set_kanji_to_expect(kanji_key)
	#kanji_to_draw = kanji_refs[kanji_key]
	#expand_strokes(kanji_to_draw)
	
func set_furigana_to_draw(sentence_obj):
	var sentence = sentence_obj.sentence.split()
	var start_word_search = false
	var draw_word = []
	var kana_array = Globals.KANA_REGULAR.split()
	var kana_small_array = Globals.KANA_SMALL.split()
	var other_array = Globals.KANA_SYMBOLS.split()
	var kanji_word_index = 0
	# find kanji word that needs to be drawn
	
	var prev_is_kanji = false
	var kanji_word_count_index = 0
	var furigana_index = 0
	var kanji_word = []
	
	for i in range(0, sentence.size()):
		var letter = sentence[i]
		print(letter)
		var letter_is_kanji = letter not in kana_array and \
			letter not in kana_small_array and \
			letter not in other_array
			
		if i != 0 and prev_is_kanji == letter_is_kanji:
			print("Non-FLIP")
		elif i == 0 and letter_is_kanji:
			print("FLIP first kanji")
			kanji_word_count_index += 1
		elif i != 0 and not prev_is_kanji and letter_is_kanji:
			kanji_word_count_index += 1
			print("FLIPPED ONE (started kanji), total kanji_word_count_index=" + str(kanji_word_count_index))
			
		if letter == "・":
			# found the furigana index we need
			#kanji_word_count_index += 1
			furigana_index = kanji_word_count_index
			break
			
		prev_is_kanji = letter_is_kanji
		
	print("furigana index="+str(furigana_index))	
		
	print({"draw_word":draw_word})
	
	var furigana_array = sentence_obj.furigana[furigana_index].split()
	current_draw_total_characters = furigana_array.size()
	var kanji_key = furigana_array[current_draw_character_index]
	$UI/KanjiDrawPanel.set_kanji_to_expect(kanji_key)
		
	
	#var kanji_key = draw_word[current_draw_character_index]
	#$UI/KanjiDrawPanel.set_kanji_to_expect(kanji_key)
	
#func _animation_changed():
	#var y_offsets = {
		#"idle": 0,
		#"idle_sword": 0,
		#"sword_draw": 0,
		#"sword_away": 0,
		#"attack_up": 0,
		#"attack_down": 0,
		#"attack_spin": 0,
		#"hurt": 0,
		#"die": 0,
		#"run": 0,
	#}
	#animated_player.offset.y = y_offsets[animated_player.animation]
			
func _animation_finished():
	
	if animated_player.animation == "sword_away":
		animated_player.animation = "idle"
		animated_player.offset.y = 0
		animated_player.play()
		
	if animated_player.animation in attacks:
		animated_player.animation = "idle_sword"
		animated_player.play()
		
		if enemy_hp > 0:
			print("battle continues, enemy_hp: " + str(enemy_hp))
			pick_random_sentence()
		#pick_random_sentence()
		#$UI/KanjiDrawPanel.reset_draw_panel()
		#$UI/KanjiDrawPanel.redraw_with_color(Color.WHITE_SMOKE)
		#replacement_type = Globals.REPLACE_TYPES.pick_random()
		#$UI/VerticalTextLabel.build_sentence(replacement_type)
		$UI/KanjiDrawPanel.enable()
	elif animated_player.animation in ["hurt"]:
		
		if player_hp <= 0:
			animated_player.animation = "die"
			animated_player.play()
			return
		
		animated_player.animation = "idle_sword"
		animated_player.play()
		$UI/KanjiDrawPanel.reset_draw_panel()
		$UI/KanjiDrawPanel.redraw_with_color(Color.WHITE_SMOKE)
		$UI/KanjiDrawPanel.enable()
		
		
		
		
		
	elif animated_player.animation == "sword_draw":
		animated_player.animation = "idle_sword"
		animated_player.play()
		
	if animated_player.animation == "die":
		Globals.AudioStreamPlayerBgMusic.stream = Globals.music_ambient1
		Globals.AudioStreamPlayerBgMusic.play()
		$AudioStreamPlayer2D.stream = Globals.fx_battle_lose
		$AudioStreamPlayer2D.play()
		player_hp = player_hp_max
		Health_bar_player.hide()
		$UI2/NextBattleButton.text = "Try again"
		$UI2/NextBattleButton.show()
		$UI/KanjiDrawPanel.hide()
		%KanjiLabel.hide()
		
		player_gold = floori(player_gold / 2)
		update_hp()
		save_game()
		
func _animation_looped_player():
	pass
	#if animated_player.animation == "run":
		#$AudioStreamPlayer2D.stream = Globals.fx_dirt_run1
		#$AudioStreamPlayer2D.stream.loop = true
		#$AudioStreamPlayer2D.play()
		
func _animation_finished_enemy():
	if animated_enemy.animation == "enemy_hurt":
		
		print({"enemy_hp":enemy_hp})
		if enemy_hp <= 0:
			animated_enemy.animation = "enemy_die"
			#animated_enemy.offset.x = 3
			animated_enemy.play()
			return
		
		animated_enemy.animation = "enemy_idle"
		animated_enemy.play()
		
	if animated_enemy.animation == "enemy_attack":
		animated_enemy.animation = "enemy_idle"
		animated_enemy.offset.x = 0
		animated_enemy.offset.y = 0
		animated_enemy.play()
		
	if animated_enemy.animation == "enemy_die":
		Globals.AudioStreamPlayerBgMusic.stream = Globals.music_ambient1
		Globals.AudioStreamPlayerBgMusic.play()
		$AudioStreamPlayer2D2.stream = Globals.fx_battle_win2
		$AudioStreamPlayer2D2.volume_db = -15.0
		$AudioStreamPlayer2D2.play()
		Health_bar_enemy.hide()
		animated_enemy.hide()
		Health_bar_player.hide()
		$UI2/NextBattleButton.text = "次 (つぎ)"
		$UI2/NextBattleButton.show()
		$UI/KanjiDrawPanel.hide()
		%KanjiLabel.hide()
		
		if level_up_during_battle:
			level_up()
			level_up_during_battle = false
		
		get_gold()
		
		show_kanji_progress()
		
		$UI/VerticalTextLabel.hide()
		$UI2/TranslateButton.hide()
		animated_player.animation = "sword_away"
		animated_player.play()

func show_kanji_progress():
	
	var kp_progress = get_kp_progress()
	
	if kp_progress.first.kanji == "":
		# No more kanji to learn
		return
		
	print(kp_progress)
	
	$KanjiProgress.show()
	
	$KanjiProgress/Control/LabelKanjiWord.text = kp_progress.first.kanji
	$KanjiProgress/Control/LabelReadingKp.text = "読み reading " + \
		str(min(kp_progress.first.r, mastery_threshold)) + "/" + str(mastery_threshold) + " KP"
	$KanjiProgress/Control/LabelWritingKp.text = "書き writing " + \
		str(min(kp_progress.first.w, mastery_threshold)) + "/" + str(mastery_threshold) + " KP"
	
	var offset = Vector2i(12, 20)
	
	for i in range(0, mastery_threshold):
		print("i: " + str(i))
		
		var diamond = TextureRect.new()
		diamond.texture = $KanjiProgress/Control/TextureDiamondBright.texture.duplicate()
		
		if i < kp_progress.first.r:
			diamond.modulate = $KanjiProgress/Control/TextureDiamondBright.modulate
			print("bright")
		else: 
			print("dark")
			diamond.modulate = $KanjiProgress/Control/TextureDiamondDark.modulate
			
		diamond.size = $KanjiProgress/Control/TextureDiamondBright.size
		diamond.scale = $KanjiProgress/Control/TextureDiamondBright.scale
		diamond.position.y = 36
		diamond.position.x = 4 + (12 * i)
		print("Assigned texture: ", diamond.texture)
		$KanjiProgress/Control/RenderedDiamonds.add_child(diamond)
		
	for i in range(0, mastery_threshold):
		print("i: " + str(i))
		
		var diamond = TextureRect.new()
		diamond.texture = $KanjiProgress/Control/TextureDiamondBright.texture.duplicate()
		
		if i < kp_progress.first.w:
			diamond.modulate = $KanjiProgress/Control/TextureDiamondBright.modulate
			print("bright")
		else: 
			print("dark")
			diamond.modulate = $KanjiProgress/Control/TextureDiamondDark.modulate
			
		diamond.size = $KanjiProgress/Control/TextureDiamondBright.size
		diamond.scale = $KanjiProgress/Control/TextureDiamondBright.scale
		diamond.position.y = 60
		diamond.position.x = 4 + (12 * i)
		print("Assigned texture: ", diamond.texture)
		$KanjiProgress/Control/RenderedDiamonds.add_child(diamond)
		
	
func get_gold():
	$Prize.show()
	
	var gold_amount = randi_range(1, enemy_level)
	
	$Prize/TextureRectCoin/GoldAmount.text = str(gold_amount)
	
	if active_item and active_item.item_name == "luckycharm": 
		active_item.applyEffect(self)
	player_gold += gold_amount
	
	update_hp()
	save_game()
	
		
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _on_kanji_draw_panel_correct_stroke(strokeIndex: Variant, stroke: Variant) -> void:
	if strokeIndex == 0 and animated_player.animation != "idle_sword":
		animated_player.animation = "sword_draw"
		animated_player.play()
		audio_player.stream = Globals.fx_sword_unsheath1
		audio_player.play()
	else:
		pass
		#audio_player.stream = Globals.fx_light_torch1
		#audio_player.play()

#func _after_correct_sound():
	#audio_player.stream = fx_sword_attack1
	#audio_player.play()

func _on_kanji_draw_panel_kanji_correct() -> void:
	
	$UI/KanjiDrawPanel.disable()
	
	current_draw_character_index += 1
	
	if current_draw_character_index >= current_draw_total_characters:
		
		#print("end of word")
		#pick_random_sentence()
		#print("attack")
		audio_player.stream = Globals.fx_sword_attack1
		audio_player.play()
		
		#audio_player.connect("", Callable(self, "_after_correct_sound"))
		$UI/KanjiDrawPanel.reset_draw_panel()
		#$UI/VerticalTextLabel.build_sentence(sentence_obj, replacement_type, current_draw_character_index)
	
		$UI/VerticalTextLabel.show_answer()
		animated_player.animation = attacks.pick_random()
		animated_player.play()
		
		%KanjiLabel.text = ""
		
		# Create a timer to delay the enemy animation
		var timer = Timer.new()
		timer.wait_time = 0.35
		timer.one_shot = true  # Makes the timer run only once
		add_child(timer)
		timer.timeout.connect(Callable(self, "play_enemy_hurt"))
		timer.start()
		
		$UI/KanjiDrawPanel.disable()
		
		current_draw_character_index = 0
		current_draw_total_characters = 0
		
		print({"progress":progress,"target_word":target_word})
	
		increment_progress()
			
		print({"progress":progress})
		
	else:
		audio_player.stream = Globals.fx_fantasy_ui4
		audio_player.play()
		# more letters to be drawn
		#print("more letters")
		$UI/KanjiDrawPanel.reset_draw_panel()
		#var kanji_key = furigana_array[current_draw_character_index]
		#$UI/KanjiDrawPanel.set_kanji_to_expect(kanji_key)
		set_char_to_draw(sentence_obj, replacement_type)
		#print("current_draw_character_index: " + str(current_draw_character_index))
		$UI/VerticalTextLabel.build_sentence(sentence_obj, replacement_type, current_draw_character_index)

func calculate_kp():
	var total = 0
	
	for item in progress:
		if progress[item].r >=5 and progress[item].w >= 5:
			total += 1
	
	player_kp = total
	update_hp()	

func reset_progress():
	if not progress.has(target_word):
		progress[target_word] = {
			"r": 0,
			"w": 0
		}
	
	if replacement_type == Globals.REPLACE_TYPE_HIRAGANA:
		progress[target_word].r = 0
	else:
		progress[target_word].w = 0
		
	%KanjiLabel.show() # since we reset to 0, show hint again
	
	calculate_kp()
	
	save_game()

func increment_progress():
	
	calculate_kp()
	
	var before_increment_kp = player_kp
	
	if not progress.has(target_word):
		progress[target_word] = {
			"r": 0,
			"w": 0
		}
	
	if replacement_type == Globals.REPLACE_TYPE_HIRAGANA:
		if not progress[target_word].has("r"):
			progress[target_word].r = 1
		elif progress[target_word].r < mastery_max:
			progress[target_word].r += 1
	else:
		if not progress[target_word].has("r"):
			progress[target_word].w = 1
		elif progress[target_word].w < mastery_max:
			progress[target_word].w += 1
	
	calculate_kp()
	
	
	
	
	if known_pool_index >= complete_pool.size():
		print("no more kanji left in the pool to learn")
		print({"progress":progress})
		save_game()
		return
		
	# if all known pool kanji are mastered (+5/+5) then add a new
	# word to the pool
	
	var all_mastered = true
	
	for item in progress:
		if progress[item].r < mastery_threshold or progress[item].w < mastery_threshold:
			all_mastered = false
			break
			
	if all_mastered:
		
		known_pool_index += 1
		
		if known_pool_index >= complete_pool.size():
			print("no more new words available")
		else:
		
			print("adding new word to the pool: " + complete_pool[known_pool_index])
			progress[complete_pool[known_pool_index]] = {
				"r": 0,
				"w": 0,
			}
		
			if true or known_pool_index % 10 == 0:
				
				
				# there is a bug here where if you level up twice
				# during the same battle, you only get credit once
				# but it's rare, so i'm ignoring it
				level_up_during_battle = true
			
			
		
	print({"progress":progress})
	
	#if player_kp > before_increment_kp:
	#	for i in range(0, player_kp - before_increment_kp):
	
	save_game()
	
func level_up():
	level_up_button.show()
	$AudioStreamPlayer2D.stream = Globals.fx_level_up1
	$AudioStreamPlayer2D.play()
	player_level += 1
	set_stats_by_level(player_level)
	
	# Recover full HP when leveling up as a bonus.
	player_hp = player_hp_max
	
	#player_hp += 5
	#player_dmg_min += 1
	#player_dmg_max += 3
	#enemy_dmg_min += 1
	#enemy_dmg_min += 3
	#enemy_hp_range_max += 5
	#enemy_hp_min += 1
	#enemy_level += 1
	
func set_stats_by_level(level):
	enemy_level = level
	player_hp_max = 10 + level * 5
	player_dmg_min = level
	player_dmg_max = 2 + level * 2
	enemy_hp_range_max = level * 8
	enemy_dmg_min = 0 + level
	enemy_dmg_max = 2 + level * 2
	enemy_hp_range_min = 2 + level * 4
	
	print({"level":level,
		"player_hp_max":player_hp_max,
		"player_dmg_min":player_dmg_min,
		"player_dmg_max":player_dmg_max,
		"enemy_hp_range_max":enemy_hp_range_max,
		"enemy_dmg_min":enemy_dmg_min,
		"enemy_dmg_max":enemy_dmg_max,
		"enemy_hp_range_min":enemy_hp_range_min,
	})
	
func play_enemy_hurt():
	print("enemy_hurt")
	
	audio_player2.stream = Globals.fx_sword_impact2
	#audio_player2.volume_db = 8
	audio_player2.play()
	
	var damage_points = randi_range(player_dmg_min, player_dmg_max) + animated_player.weapon_dmg
	
	enemy_hp -= damage_points
	update_hp()
	
	print({"enemy_hp":enemy_hp})
	if enemy_hp <= 0:
		animated_enemy.animation = "enemy_die"
		animated_enemy.play()
	else:
		animated_enemy.animation = "enemy_hurt"
		animated_enemy.play()
	
	var tween = create_tween()
	enemy_damage_label.show()
	enemy_damage_label.text = str(damage_points)
	enemy_damage_label.position.y = default_damage_label_y
	enemy_damage_label.modulate = default_damage_label_color
	tween.parallel().tween_property(enemy_damage_label, "position:y", default_damage_label_y - 20, 1)
	tween.parallel().tween_property(enemy_damage_label, "modulate", Color(0, 0, 0, 0), 1)
	
	#if false and enemy_hp <= 0:
		## Create a timer to delay the enemy animation
		#var timer = Timer.new()
		#timer.wait_time = 1
		#timer.one_shot = true  # Makes the timer run only once
		#add_child(timer)
		#timer.timeout.connect(Callable(self, "play_enemy_dead"))
		#timer.start()
	
#func xxxplay_enemy_dead():
	#$AudioStreamPlayerBgMusic.stream = Globals.music_ambient1
	#$AudioStreamPlayerBgMusic.play()
	#$AudioStreamPlayer2D.stream = Globals.fx_battle_win2
	#$AudioStreamPlayer2D.play()
	
func _on_kanji_draw_panel_kanji_incorrect() -> void:
	
	if debug_detector_mode:
		return
	
	animated_enemy.animation = "enemy_attack"
	animated_enemy.offset.x = -16
	animated_enemy.offset.y = -5
	animated_enemy.play()
	
	var timer = Timer.new()
	timer.wait_time = 0.7
	timer.one_shot = true  # Makes the timer run only once
	add_child(timer)
	timer.timeout.connect(Callable(self, "play_player_hurt"))
	timer.start()
	
	audio_player.stream = Globals.fx_incorrect
	audio_player.play()
	$UI/KanjiDrawPanel.redraw_with_color(Color.RED)
	
	reset_progress()

func play_player_hurt():
	animated_player.animation = "hurt"
	animated_player.play()
	
	audio_player2.stream = Globals.fx_sword_impact2
	#audio_player2.volume_db = 8
	audio_player2.play()
	
	var damage_points = randi_range(enemy_dmg_min, enemy_dmg_max)
	
	if active_item and active_item.item_name == "shield": 
		active_item.applyEffect(self)
	elif active_item and active_item.item_name == "luckycharm": 
		active_item.customEffect("lose_streak")
	else: 
		player_hp -= damage_points
	
	update_hp()
	
	var tween = create_tween()
	player_damage_label.show()
	player_damage_label.text = str(damage_points)
	player_damage_label.position.y = default_damage_label_y
	player_damage_label.modulate = default_damage_label_color
	tween.parallel().tween_property(player_damage_label, "position:y", default_damage_label_y - 20, 1)
	tween.parallel().tween_property(player_damage_label, "modulate", Color(0, 0, 0, 0), 1)

func get_kp_progress():
	
	var kp_progress = {
		"goal": 0,
		"current": 0,
		"first": {
			"kanji": "",
			"r": 0,
			"w": 0,
		}
	}
	
	kp_progress.goal = progress.size() * mastery_threshold * 2
	
	for kanji_item in progress:
		if progress[kanji_item].r < mastery_threshold:
			kp_progress.current += progress[kanji_item].r
			#kp_progress.goal += mastery_threshold
			if kp_progress.first.kanji == "":
				kp_progress.first.kanji = kanji_item
				kp_progress.first.r = progress[kanji_item].r
				kp_progress.first.w = min(progress[kanji_item].w, mastery_threshold)
		else:
			kp_progress.current += mastery_threshold
			
		if progress[kanji_item].w < mastery_threshold:
			kp_progress.current += progress[kanji_item].w
			#kp_progress.goal += mastery_threshold
			if kp_progress.first.kanji == "":
				kp_progress.first.kanji = kanji_item
				kp_progress.first.r = min(progress[kanji_item].r, mastery_threshold)
				kp_progress.first.w = progress[kanji_item].w
		else:
			kp_progress.current += mastery_threshold
			
	return kp_progress 		
	
func update_hp():
	
	if player_hp < 0:
		player_hp = 0
	
	Health_bar_player.max_value = player_hp_max
	Health_bar_player.value = player_hp
	
	Health_bar_enemy.max_value = enemy_hp_max
	Health_bar_enemy.value = enemy_hp
	
	var kp_progress = get_kp_progress()
	
	$UI2/PlayerStats.text = Globals.player_name + "\n" +\
		"レベル: " + str(player_level) + "\n" +\
		"HP: " + str(player_hp) + "/" + str(player_hp_max) + "\n" +\
		"KP: " + str(kp_progress.current) + "/" + str(kp_progress.goal) + "\n" +\
		#"EXP: " + str(player_exp) + "\n" +\
		"ゴールド: " + str(player_gold)
		
	if enemy_hp > 0:
		$UI2/EnemyStats.text = enemy_name + "\n" +\
			"レベル: " + str(enemy_level)
	else:
		$UI2/EnemyStats.text = ""
		
	print({
		"player_hp":player_hp,
		"enemy_hp_max":enemy_hp_max,
		"enemy_hp":enemy_hp
	})

func _on_try_again_button_gui_input(event: InputEvent) -> void:
	#print(event)
	if event is InputEventMouseButton and event.button_index == 1:
		#$UI/ResultLabel.text = ""
		$UI/TryAgainButton.hide()
		$UI/KanjiDrawPanel.reset_draw_panel()
		$UI/KanjiDrawPanel.redraw_with_color(Color.WHITE_SMOKE)


func _on_komoji_button_toggled(toggled_on: bool) -> void:
	if toggled_on:
		audio_player.stream = Globals.fx_chop1
		audio_player.play(0.3)
		$UI/KomojiLabel.show()
	else:
		audio_player.stream = Globals.fx_mine4
		audio_player.play(0.1)
		$UI/KomojiLabel.hide()

func _on_next_battle_button_button_up() -> void:
	
	$UI2/NextBattleButton.hide()
	$UI/VerticalTextLabel.hide()
	$UI2/TranslateButton.hide()
	$Prize.hide()
	level_up_button.hide()
	$KanjiProgress.hide()
	
	audio_player.stream = Globals.fx_chop1
	audio_player.play(0.3)
	
	world.run_to_next_npc()
	
	#animated_player.animation = "run"
	#animated_player.play()
	
	#$AudioStreamPlayer2D.stream = Globals.fx_dirt_run1
	#$AudioStreamPlayer2D.stream.loop = true
	#$AudioStreamPlayer2D.play()
	
	#var tween = create_tween()
	#tween.connect("finished", Callable(self, "_encounter_enemy"))
	#tween.parallel().tween_property(tile_map_layer, "position:x", -90, 2)
	#tween.parallel().tween_property(decor2, "position:x", 80, 2)
	#tween.parallel().tween_property(decor1, "position:x", -80, 2)
	
	#Health_bar_enemy.hide()
	
	#animated_enemy.position.x = 250
	#animated_enemy.show()
	#animated_enemy.animation = "enemy_idle"
	#animated_enemy.play()
	#tween.parallel().tween_property(animated_enemy, "position:x", 76, 2)
	
func _encounter_enemy():
	animated_player.animation = "idle"
	animated_player.offset.y = 0
	animated_player.play()
	
	$AudioStreamPlayer2D.stop()
	Health_bar_enemy.show()
	
	print("_encounter_enemy")
	
	start_battle()
	
	
	
func start_battle():
	audio_player.stream = Globals.fx_mine4
	audio_player.play(0.1)
	
	$UI2/NextBattleButton.hide()
	level_up_button.hide()
	$UI/KanjiDrawPanel.show()
	$UI/KanjiDrawPanel.enable()
	$UI/KanjiDrawPanel.redraw_with_color(Color.WHITE_SMOKE)
	#tile_map_layer.position.x = 90
	
	#decor1.position.x = 80
	#decor2.position.x = 245

	$UI/VerticalTextLabel.show()
	$UI2/TranslateButton.show()
	translation_mode = "Jp"
	$UI2/TranslateButton.text = "Jp"
	$UI2/AltLangText.hide()
	%KanjiLabel.show()
	
	enemy_hp_max = randi_range(enemy_hp_range_min, enemy_hp_range_max)
	enemy_hp = enemy_hp_max

	$Prize.hide()
	
	if player_hp <= 0:
		player_hp = player_hp_max
	
	update_hp()
	
	pick_random_sentence()
	animated_enemy.show()
	animated_enemy.animation = "enemy_idle"
	animated_enemy.play()
	
	animated_player.animation = "idle"
	animated_player.offset.y = 0
	animated_enemy.play()
	
	Health_bar_player.show()
	Health_bar_enemy.show()

	Globals.AudioStreamPlayerBgMusic.stream = Globals.music_action1
	Globals.AudioStreamPlayerBgMusic.play()
	
func _on_level_up_button_button_up() -> void:
	audio_player.stream = Globals.fx_chop1
	audio_player.play(0.3)
	level_up_button.hide()


func _on_menu_menu_button_button_up() -> void:
	Globals.AudioStreamPlayerBgMusic.stop()
	Globals.AudioStreamPlayerBgMusic.stream = null
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")


func _on_translate_button_button_up() -> void:
	Globals.AudioStreamPlayerSoundFx.stream = Globals.fx_chop1
	Globals.AudioStreamPlayerSoundFx.play(0.3)
	
	$UI2/AltLangText.text = sentence_obj.en
	
	if translation_mode == "Jp":
		translation_mode = "En"
		$UI2/TranslateButton.text = "En"
		$UI2/AltLangText.show()
		$UI/VerticalTextLabel.hide()
	elif translation_mode == "En":
		translation_mode = "Jp"
		$UI2/TranslateButton.text = "Jp"
		$UI2/AltLangText.hide()
		$UI/VerticalTextLabel.show()


func _on_debug_button_1_button_up() -> void:
	progress = {
	  "一": {"r": 99, "w": 99},
	  "二": {"r": 99, "w": 99},
	  "三": {"r": 99, "w": 99},
	  "四": {"r": 99, "w": 99},
	  "五": {"r": 99, "w": 99},
	  "六": {"r": 99, "w": 99},
	  "七": {"r": 99, "w": 99},
	  "八": {"r": 99, "w": 99},
	  "九": {"r": 99, "w": 99},
	  "十": {"r": 99, "w": 5},
	}

	known_pool_index = 9
	start_battle()
