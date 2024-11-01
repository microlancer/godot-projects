extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$Panel/Label.size = $Panel.size
	$Panel/Label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER

	$Panel/Label2.size = $Panel.size
	$Panel/Label2.vertical_alignment = VERTICAL_ALIGNMENT_CENTER

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
