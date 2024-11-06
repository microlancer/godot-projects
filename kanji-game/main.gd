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
#@export var replacement_type = Globals.REPLACE_TYPE_HIRAGANA

@onready var audio_player: AudioStreamPlayer2D = %AudioStreamPlayer2D  # Adjust the path if necessary
@onready var audio_player2: AudioStreamPlayer2D = %AudioStreamPlayer2D2  # Adjust the path if necessary

var default_damage_label_y = 0
var default_damage_label_color

var player_hp_max = 5
var player_hp = 5
var enemy_hp_max = 5
var enemy_hp = 5

var player_dmg_min = 1
var player_dmg_max = 5

var enemy_dmg_min = 1
var enemy_dmg_max = 5

var player_level = 1
var enemy_level = 1
var enemy_name = "Skeleton"
var player_name = "Player"
var player_kp = 0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$AnimatedSprite2DPlayer.connect("animation_changed", Callable(self, "_animation_changed"))
	$AnimatedSprite2DPlayer.connect("animation_finished", Callable(self, "_animation_finished"))
	$AnimatedSprite2DPlayer.animation = "idle"
	$AnimatedSprite2DPlayer.play()
	
	$AnimatedSprite2DEnemy.connect("animation_finished", Callable(self, "_animation_finished_enemy"))
	$AnimatedSprite2DEnemy.animation = "enemy_idle"
	$AnimatedSprite2DEnemy.play()
	#$AudioStreamPlayerBgMusic.play()
	is_battle_start = true
	
	default_damage_label_y = $Control2/EnemyDamageLabel.position.y
	default_damage_label_color = $Control2/EnemyDamageLabel.modulate
	$Control2/EnemyDamageLabel.hide()
	$Control2/PlayerDamageLabel.hide()
	
	player_hp = player_hp_max
	enemy_hp = enemy_hp_max
	update_hp()
	
	#$Control2/HealthBarPlayer.max_value = player_hp_max
	#$Control2/HealthBarPlayer.value = player_hp
	#
	#$Control2/HealthBarEnemy.max_value = enemy_hp_max
	#$Control2/HealthBarEnemy.value = enemy_hp
	
	var file_path = "res://kanji_data.json"
	var json_as_text = FileAccess.get_file_as_string(file_path)
	var kanji_data = JSON.parse_string(json_as_text)
	kanji_sentences = kanji_data.quiz_level_01
	#kanji_refs = kanji_data.refs
	
	$Control/KanjiDrawPanel.kanji_refs = kanji_data.refs
	
	pick_random_sentence()
	
	$Control2/NextBattleButton.hide()
	
	#replacement_type = Globals.REPLACE_TYPES.pick_random()
	
	return
	
func pick_random_sentence():
	
	
	print("picking random sentence")
	sentence_obj = kanji_sentences.pick_random()
	replacement_type = Globals.REPLACE_TYPES.pick_random()
	
	if 0:
		sentence_obj = kanji_sentences[1]
		replacement_type = Globals.REPLACE_TYPE_HIRAGANA
	
	print("replacement_type: " + str(replacement_type))
	current_draw_character_index = 0
	current_draw_total_characters = 0
		
	set_char_to_draw(sentence_obj, replacement_type)
	
	$Control/VerticalTextLabel.build_sentence(sentence_obj, replacement_type)
	
	#$"../KanjiLabel".text = "[center]" + kanji_key + "[/center]"
	#$"../SentenceLabel".text = "[center]" + sentence_obj.sentence + "[/center]"
	
func set_char_to_draw(sentence_obj, replacement_type):
	
	if replacement_type == Globals.REPLACE_TYPE_HIRAGANA:
		set_furigana_to_draw(sentence_obj)
	else:
		set_kanji_to_draw(sentence_obj)
		
func set_kanji_to_draw(sentence_obj):
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
	
	var kanji_key = draw_word[current_draw_character_index]
	$Control/KanjiDrawPanel.set_kanji_to_expect(kanji_key)
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
		
	var furigana_array = sentence_obj.furigana[furigana_index].split()
	current_draw_total_characters = furigana_array.size()
	var kanji_key = furigana_array[current_draw_character_index]
	$Control/KanjiDrawPanel.set_kanji_to_expect(kanji_key)
		
	
	#var kanji_key = draw_word[current_draw_character_index]
	#$Control/KanjiDrawPanel.set_kanji_to_expect(kanji_key)
	
func _animation_changed():
	var y_offsets = {
		"idle": 3,
		"idle_sword": 0,
		"sword_draw": 0,
		"sword_away": 0,
		"attack_up": 0,
		"attack_down": 0,
		"attack_spin": 0,
		"hurt": 0,
		"die": 0,
	}
	$AnimatedSprite2DPlayer.offset.y = y_offsets[$AnimatedSprite2DPlayer.animation]
			
func _animation_finished():
	
	if $AnimatedSprite2DPlayer.animation == "sword_away":
		$AnimatedSprite2DPlayer.animation = "idle"
		$AnimatedSprite2DPlayer.offset.y = 0
		$AnimatedSprite2DPlayer.play()
		
	if $AnimatedSprite2DPlayer.animation in attacks:
		$AnimatedSprite2DPlayer.animation = "idle_sword"
		$AnimatedSprite2DPlayer.play()
		
		if enemy_hp > 0:
			print("battle continues, enemy_hp: " + str(enemy_hp))
			pick_random_sentence()
		#pick_random_sentence()
		#$Control/KanjiDrawPanel.reset_draw_panel()
		#$Control/KanjiDrawPanel.redraw_with_color(Color.WHITE_SMOKE)
		#replacement_type = Globals.REPLACE_TYPES.pick_random()
		#$Control/VerticalTextLabel.build_sentence(replacement_type)
		$Control/KanjiDrawPanel.enable()
	elif $AnimatedSprite2DPlayer.animation in ["hurt"]:
		
		if player_hp <= 0:
			$AnimatedSprite2DPlayer.animation = "die"
			$AnimatedSprite2DPlayer.play()
			return
		
		$AnimatedSprite2DPlayer.animation = "idle_sword"
		$AnimatedSprite2DPlayer.play()
		$Control/KanjiDrawPanel.reset_draw_panel()
		$Control/KanjiDrawPanel.redraw_with_color(Color.WHITE_SMOKE)
		$Control/KanjiDrawPanel.enable()
		
		
		
		
	elif $AnimatedSprite2DPlayer.animation == "sword_draw":
		$AnimatedSprite2DPlayer.animation = "idle_sword"
		$AnimatedSprite2DPlayer.play()
		
	if $AnimatedSprite2DPlayer.animation == "die":
		$AudioStreamPlayerBgMusic.stream = Globals.music_ambient1
		$AudioStreamPlayerBgMusic.play()
		$AudioStreamPlayer2D.stream = Globals.fx_battle_lose
		$AudioStreamPlayer2D.play()
		player_hp = player_hp_max
		$Control2/HealthBarPlayer.hide()
		$Control2/NextBattleButton.text = "Try again"
		$Control2/NextBattleButton.show()
		$Control/KanjiDrawPanel.hide()
		$Control/KanjiLabel.hide()
		
func _animation_finished_enemy():
	if $AnimatedSprite2DEnemy.animation == "enemy_hurt":
		
		print({"enemy_hp":enemy_hp})
		if enemy_hp <= 0:
			$AnimatedSprite2DEnemy.animation = "enemy_die"
			#$AnimatedSprite2DEnemy.offset.x = 3
			$AnimatedSprite2DEnemy.play()
			return
		
		$AnimatedSprite2DEnemy.animation = "enemy_idle"
		$AnimatedSprite2DEnemy.play()
		
	if $AnimatedSprite2DEnemy.animation == "enemy_attack":
		$AnimatedSprite2DEnemy.animation = "enemy_idle"
		$AnimatedSprite2DEnemy.offset.x = 0
		$AnimatedSprite2DEnemy.offset.y = 0
		$AnimatedSprite2DEnemy.play()
		
	if $AnimatedSprite2DEnemy.animation == "enemy_die":
		$AudioStreamPlayerBgMusic.stream = Globals.music_ambient1
		$AudioStreamPlayerBgMusic.play()
		$AudioStreamPlayer2D.stream = Globals.fx_battle_win2
		$AudioStreamPlayer2D.play()
		$Control2/HealthBarEnemy.hide()
		$AnimatedSprite2DEnemy.hide()
		$Control2/HealthBarPlayer.hide()
		$Control2/NextBattleButton.text = "Next battle"
		$Control2/NextBattleButton.show()
		$Control/KanjiDrawPanel.hide()
		$Control/KanjiLabel.hide()
		#$Control/VerticalTextLabel.hide()
		$AnimatedSprite2DPlayer.animation = "sword_away"
		$AnimatedSprite2DPlayer.play()
		
		
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _on_kanji_draw_panel_correct_stroke(strokeIndex: Variant, stroke: Variant) -> void:
	if strokeIndex == 0 and $AnimatedSprite2DPlayer.animation != "idle_sword":
		$AnimatedSprite2DPlayer.animation = "sword_draw"
		$AnimatedSprite2DPlayer.play()
		audio_player.stream = Globals.fx_sword_unsheath1
		audio_player.play()
	else:
		audio_player.stream = Globals.fx_light_torch1
		audio_player.play()

#func _after_correct_sound():
	#audio_player.stream = fx_sword_attack1
	#audio_player.play()

func _on_kanji_draw_panel_kanji_correct() -> void:
	
	current_draw_character_index += 1
	
	if current_draw_character_index >= current_draw_total_characters:
		
		#print("end of word")
		#pick_random_sentence()
		#print("attack")
		audio_player.stream = Globals.fx_sword_attack1
		audio_player.play()
		
		#audio_player.connect("", Callable(self, "_after_correct_sound"))
		$Control/KanjiDrawPanel.reset_draw_panel()
		#$Control/VerticalTextLabel.build_sentence(sentence_obj, replacement_type, current_draw_character_index)
	
		$Control/VerticalTextLabel.show_answer()
		$AnimatedSprite2DPlayer.animation = attacks.pick_random()
		$AnimatedSprite2DPlayer.play()
		
		$Control/KanjiLabel.text = ""
		
		# Create a timer to delay the enemy animation
		var timer = Timer.new()
		timer.wait_time = 0.35
		timer.one_shot = true  # Makes the timer run only once
		add_child(timer)
		timer.timeout.connect(Callable(self, "play_enemy_hurt"))
		timer.start()
		
		$Control/KanjiDrawPanel.disable()
		
		current_draw_character_index = 0
		current_draw_total_characters = 0
		
	else:
		audio_player.stream = Globals.fx_fantasy_ui4
		audio_player.play()
		# more letters to be drawn
		#print("more letters")
		$Control/KanjiDrawPanel.reset_draw_panel()
		#var kanji_key = furigana_array[current_draw_character_index]
		#$Control/KanjiDrawPanel.set_kanji_to_expect(kanji_key)
		set_char_to_draw(sentence_obj, replacement_type)
		#print("current_draw_character_index: " + str(current_draw_character_index))
		$Control/VerticalTextLabel.build_sentence(sentence_obj, replacement_type, current_draw_character_index)
	
func play_enemy_hurt():
	print("enemy_hurt")
	
	audio_player2.stream = Globals.fx_sword_impact2
	#audio_player2.volume_db = 8
	audio_player2.play()
	
	var damage_points = randi_range(player_dmg_min, player_dmg_max)
	
	enemy_hp -= damage_points
	update_hp()
	
	print({"enemy_hp":enemy_hp})
	if enemy_hp <= 0:
		$AnimatedSprite2DEnemy.animation = "enemy_die"
		$AnimatedSprite2DEnemy.play()
	else:
		$AnimatedSprite2DEnemy.animation = "enemy_hurt"
		$AnimatedSprite2DEnemy.play()
	
	var tween = create_tween()
	$Control2/EnemyDamageLabel.show()
	$Control2/EnemyDamageLabel.text = str(damage_points)
	$Control2/EnemyDamageLabel.position.y = default_damage_label_y
	$Control2/EnemyDamageLabel.modulate = default_damage_label_color
	tween.parallel().tween_property($Control2/EnemyDamageLabel, "position:y", default_damage_label_y - 20, 1)
	tween.parallel().tween_property($Control2/EnemyDamageLabel, "modulate", Color(0, 0, 0, 0), 1)
	
	if false and enemy_hp <= 0:
		# Create a timer to delay the enemy animation
		var timer = Timer.new()
		timer.wait_time = 1
		timer.one_shot = true  # Makes the timer run only once
		add_child(timer)
		timer.timeout.connect(Callable(self, "play_enemy_dead"))
		timer.start()
	
func xxxplay_enemy_dead():
	$AudioStreamPlayerBgMusic.stream = Globals.music_ambient1
	$AudioStreamPlayerBgMusic.play()
	$AudioStreamPlayer2D.stream = Globals.fx_battle_win2
	$AudioStreamPlayer2D.play()
	
func _on_kanji_draw_panel_kanji_incorrect() -> void:
	$AnimatedSprite2DEnemy.animation = "enemy_attack"
	$AnimatedSprite2DEnemy.offset.x = -16
	$AnimatedSprite2DEnemy.offset.y = -5
	$AnimatedSprite2DEnemy.play()
	
	var timer = Timer.new()
	timer.wait_time = 0.7
	timer.one_shot = true  # Makes the timer run only once
	add_child(timer)
	timer.timeout.connect(Callable(self, "play_player_hurt"))
	timer.start()
	
	audio_player.stream = Globals.fx_incorrect
	audio_player.play()
	$Control/KanjiDrawPanel.redraw_with_color(Color.RED)

func play_player_hurt():
	$AnimatedSprite2DPlayer.animation = "hurt"
	$AnimatedSprite2DPlayer.play()
	
	audio_player2.stream = Globals.fx_sword_impact2
	#audio_player2.volume_db = 8
	audio_player2.play()
	
	var damage_points = randi_range(enemy_dmg_min, enemy_dmg_max)
	player_hp -= damage_points
	update_hp()
	
	var tween = create_tween()
	$Control2/PlayerDamageLabel.show()
	$Control2/PlayerDamageLabel.text = str(damage_points)
	$Control2/PlayerDamageLabel.position.y = default_damage_label_y
	$Control2/PlayerDamageLabel.modulate = default_damage_label_color
	tween.parallel().tween_property($Control2/PlayerDamageLabel, "position:y", default_damage_label_y - 20, 1)
	tween.parallel().tween_property($Control2/PlayerDamageLabel, "modulate", Color(0, 0, 0, 0), 1)
	
func update_hp():
	
	if player_hp < 0:
		player_hp = 0
	
	$Control2/HealthBarPlayer.value = player_hp
	$Control2/HealthBarEnemy.value = enemy_hp
	
	$Control2/HealthBarEnemy.max_value = enemy_hp_max
	$Control2/HealthBarPlayer.max_value = player_hp_max
	
	$Control2/PlayerStats.text = player_name + "\n" +\
		"Lv: " + str(player_level) + "\n" +\
		"HP: " + str(player_hp) + "/" + str(player_hp_max) + "\n" +\
		"KP: " + str(player_kp)
		
	if enemy_hp > 0:
		$Control2/EnemyStats.text = enemy_name + "\n" +\
			"Lv: " + str(enemy_level)
	else:
		$Control2/EnemyStats.text = ""
		

func _on_try_again_button_gui_input(event: InputEvent) -> void:
	#print(event)
	if event is InputEventMouseButton and event.button_index == 1:
		#$Control/ResultLabel.text = ""
		#$Control/TryAgainButton.hide()
		$Control/KanjiDrawPanel.reset_draw_panel()
		$Control/KanjiDrawPanel.redraw_with_color(Color.WHITE_SMOKE)


func _on_komoji_button_toggled(toggled_on: bool) -> void:
	if toggled_on:
		audio_player.stream = Globals.fx_chop1
		audio_player.play(0.3)
		$Control/KomojiLabel.show()
	else:
		audio_player.stream = Globals.fx_mine4
		audio_player.play(0.1)
		$Control/KomojiLabel.hide()

func _on_next_battle_button_button_up() -> void:
	audio_player.stream = Globals.fx_mine4
	audio_player.play(0.1)
	
	$Control2/NextBattleButton.hide()
	$Control/KanjiDrawPanel.show()
	$Control/KanjiDrawPanel.enable()
	$Control/KanjiDrawPanel.redraw_with_color(Color.WHITE_SMOKE)

	$Control/VerticalTextLabel.show()
	$Control/KanjiLabel.show()
	
	enemy_hp = enemy_hp_max
	
	if player_hp <= 0:
		player_hp = player_hp_max
	
	update_hp()
	
	pick_random_sentence()
	$AnimatedSprite2DEnemy.show()
	$AnimatedSprite2DEnemy.animation = "enemy_idle"
	$AnimatedSprite2DEnemy.play()
	
	$AnimatedSprite2DPlayer.animation = "idle"
	$AnimatedSprite2DPlayer.offset.y = 0
	$AnimatedSprite2DEnemy.play()
	
	$Control2/HealthBarPlayer.show()
	$Control2/HealthBarEnemy.show()

	$AudioStreamPlayerBgMusic.stream = Globals.music_action1
	$AudioStreamPlayerBgMusic.play()
	
	
		
	
	
