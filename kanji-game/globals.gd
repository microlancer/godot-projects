extends Node


const REPLACE_TYPE_HIRAGANA = "hiragana"
const REPLACE_TYPE_KANJI = "kanji"
const REPLACE_TYPES = [REPLACE_TYPE_HIRAGANA, REPLACE_TYPE_KANJI]

var KANA_REGULAR = \
	"あいうえお" + \
	"アイウエオ" + \
	"かきくけこ" + \
	"さしすせそ" + \
	"たちつてと" + \
	"なにぬねの" + \
	"はひふへほ" + \
	"まみむめも" + \
	"マミムメモ" + \
	"やゆよ" + \
	"らりるれろ" + \
	"ラリルレロ" + \
	"わをん" + \
	"ワヲン" + \
	"がぎぐげご" + \
	"ざじずぜぞ" + \
	"だぢづでど" + \
	"ぱぴぷぺぽ" + \
	"ばびぶべぼ"
var KANA_SMALL = "ゃっ"
var KANA_SYMBOLS = "ー。！？、「」　・"

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# From https://drtwelele.itch.io/casual-game-fx-one-shot
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
