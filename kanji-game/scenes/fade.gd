extends ColorRect

func _ready():
	visible = true
	modulate.a = 1
	fade_out()

func fade_out():
	var tween = create_tween()
	tween.tween_property(
		self, "modulate:a", 0.0, 0.9
	).set_ease(Tween.EASE_IN)
