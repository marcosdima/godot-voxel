@tool
extends SpinBox
class_name LayerPicker


func _ready():
	value = 0
	min_value = 0 # Zero-based layer index.
	max_value = 99 # Arbitrary limit, can be adjusted as needed.
