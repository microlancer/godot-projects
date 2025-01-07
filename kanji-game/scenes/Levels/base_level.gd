extends Node
class_name  BaseLevel

@export var enemies: Array[EnemyResource] = []
@export var ref_json: JSON 
@export var sentence_json: JSON 
@export var pool_json: JSON = null

# ref (n5_refs.json) file format  
#{
	#"一": {
		#"unicode": 19968,
		#"readings": ["いち"],
		#"stroke_count": 1,
		#"strokes": [["R","UR"]]
	#},
#}

# sentence (n5.json) file format
#{ 
	#"お皿": {
		#"order": "1",
		#"word": "お皿",
		#"sentence": "私は・お皿・を洗う。",
		#"furigana": [
			#"さら",
			#"あらう"
		#],
		#"en": "I \/wash\/ the dishes."
	#},
#}
func load_kanji(): 
	var pool = []
	if pool_json != null: 
		# load pool here 
		pass 
	var sentences = null
	
	if sentence_json:
		sentences = JSON.parse_string(JSON.stringify(sentence_json.data))
	var refs = null 
	if ref_json:
		refs = JSON.parse_string(JSON.stringify(ref_json.data))
	var res = { 
		"pool": pool, 
		"sentences":sentences,
		"refs": refs
	} 
	
	return res
	
