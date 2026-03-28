@tool
extends SpinBox
class_name LayerPicker


func _ready():
	# Layer picker uses zero-based layer indexes.
	value = 0
	min_value = 0

	# Keep an editor-friendly upper bound.
	max_value = 99
