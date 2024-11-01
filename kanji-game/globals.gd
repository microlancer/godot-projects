extends Node


const REPLACE_TYPE_HIRAGANA = "hiragana"
const REPLACE_TYPE_KANJI = "kanji"
const REPLACE_TYPES = [REPLACE_TYPE_HIRAGANA, REPLACE_TYPE_KANJI]

var KANA_REGULAR = \
	"あいうえお" + \
	"かきくけこさしすせそたちつてと" + \
	"なにぬねのはひふへほまみむめもやゆよらりるれろわをん" + \
	"がぎぐげござじずぜぞだぢづでど" + \
	"ぱぴぷぺぽ"
var KANA_SMALL = "ゃっ"
var KANA_SYMBOLS = "。！？、「」　・"

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
