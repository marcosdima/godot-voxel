@tool
extends SpinBox
class_name LayerPicker


func _ready():
	value = 1
	min_value = 1 # Always positive.
	max_value = 99 # Arbitrary limit, can be adjusted as needed.
