extends Node
class_name  BaseLevel

@export var enemies: Array[EnemyResource] = []
@export var sentence_ref_path: JSON 
@export var sentence_file_path: JSON 


# ref file format  
#{
	#"一": {
		#"unicode": 19968,
		#"readings": ["いち"],
		#"stroke_count": 1,
		#"strokes": [["R","UR"]]
	#},
#}

# sentence file format
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
