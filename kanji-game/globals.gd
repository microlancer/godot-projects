extends Node


const REPLACE_TYPE_HIRAGANA = "hiragana"
const REPLACE_TYPE_KANJI = "kanji"
const REPLACE_TYPES = [REPLACE_TYPE_HIRAGANA, REPLACE_TYPE_KANJI]

var KANA_REGULAR = \
	"あいうえお" + \
	"アイウエオ" + \
	"かきくけこ" + \
	"がぎぐげご" + \
	"カキクケコ" + \
	"ガギグゲゴ" + \
	"さしすせそ" + \
	"ざじずぜぞ" + \
	"サシスセソ" + \
	"ザジズゼゾ" + \
	"たちつてと" + \
	"だぢづでど" + \
	"タチツテト" + \
	"ダヂヅデド" + \
	"なにぬねの" + \
	"ナニヌネノ" + \
	"はひふへほ" + \
	"ばびぶべぼ" + \
	"ぱぴぷぺぽ" + \
	"ハヒフヘホ" + \
	"バビブベボ" + \
	"パピプペポ" + \
	"まみむめも" + \
	"マミムメモ" + \
	"やゆよ" + \
	"ヤユヨ" + \
	"らりるれろ" + \
	"ラリルレロ" + \
	"わをん" + \
	"ワヲン"
var KANA_SMALL = "ぁぃぅぇぉっゃゅょァィゥェォッャュョ"
var KANA_SYMBOLS = "ー。！？、「」　・｜"

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	AudioStreamPlayerBgMusic = AudioStreamPlayer2D.new()
	add_child(AudioStreamPlayerBgMusic)
	AudioStreamPlayerSoundFx = AudioStreamPlayer2D.new()
	add_child(AudioStreamPlayerSoundFx)


# From https://drtwelele.itch.io/casual-game-fx-one-shot
var fx_dirt_run1: AudioStream = preload("res://sound_fx/Dirt Run 1.ogg")
var fx_incorrect: AudioStream = preload("res://sound_fx/wind down 1.wav")
var fx_correct: AudioStream = preload("res://sound_fx/wind up 1.wav")
var fx_chop1: AudioStream = preload("res://sound_fx/chop 1.wav")
var fx_chop2: AudioStream = preload("res://sound_fx/chop 2.wav")
var fx_mine4: AudioStream = preload("res://sound_fx/mine 4.wav")
var fx_sword_unsheath1: AudioStream = preload("res://sound_fx/Sword Unsheath 1.wav")
var fx_fantasy_ui4: AudioStream = preload("res://sound_fx/Fantasy_UI (4).wav")
var fx_fantasy_ui8: AudioStream = preload("res://sound_fx/Fantasy_UI (8).wav")
var fx_light_torch1: AudioStream = preload("res://sound_fx/Light Torch 1.wav")
var fx_sword_attack1: AudioStream = preload("res://sound_fx/Sword Attack 1.wav")
var fx_sword_attack2: AudioStream = preload("res://sound_fx/Sword Attack 2.wav")
var fx_sword_attack3: AudioStream = preload("res://sound_fx/Sword Attack 3.wav")
var fx_sword_impact2: AudioStream = preload("res://sound_fx/Sword Impact Hit 2.wav")
var music_ambient1: AudioStream = preload("res://music/Ambient 1.mp3")
var music_action1: AudioStream = preload("res://music/Action 1.mp3")
var fx_battle_win: AudioStream = preload("res://music/Fx 1.wav")
var fx_battle_lose: AudioStream = preload("res://music/Fx 3.wav")
var fx_battle_win2: AudioStream = preload("res://music/Action RPG music by escalonamusic/MS01triumph3NL.wav")
var fx_level_up1: AudioStream = preload("res://sound_fx/MS01triumph2NL.wav")

var custom_skip_kanji_list: String = ""
var custom_bg_music_enabled: bool = true

var AudioStreamPlayerBgMusic: AudioStreamPlayer2D
var AudioStreamPlayerSoundFx: AudioStreamPlayer2D
var player_name: String = "プレイヤー"

var large_kanji_position = Vector2i(0, -8)
var large_kanji_scale = Vector2(1.0, 1.0)

func save_settings():
	var file = FileAccess.open("user://settings.json", FileAccess.WRITE)
	var save_data = {
		"bg_music_enabled": Globals.custom_bg_music_enabled,
		"player_name": Globals.player_name,
		"custom_skip_kanji_list": Globals.custom_skip_kanji_list
	}
	print({"save_data":save_data})
	file.store_string(JSON.stringify(save_data))
