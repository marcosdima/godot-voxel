@tool
extends VBoxContainer
class_name VoxelEditor


@export var data: VoxelEditorConfig
@export_group("UI Elements")
@export var grid: GridContainer
@export var current_layer: LayerPicker

var layer_cells: int:
	get():
		return data.width * data.height


func _ready() -> void:
	if not Engine.is_editor_hint():
		# Configure layer picker before building UI to avoid invalid initial indices.
		current_layer.min_value = 0
		current_layer.max_value = data.layers - 1
		current_layer.value = clamp(current_layer.value, current_layer.min_value, current_layer.max_value)

		_build_grid()

		# Connect layer change signal to update the grid when the layer is changed.
		current_layer.value_changed.connect(_update_layer_cells)


func _build_grid() -> void:
	# Set grid columns to match the width of the voxel editor configuration.
	grid.columns = data.width

	# Ensure every [layer, x, y] entry exists at its exact array index.
	for layer in range(data.layers):
		for i in range(layer_cells):
			var cell_index := layer * layer_cells + i
			var cell_data = data.cells[cell_index] if cell_index < data.cells.size() else null
			if cell_data == null:
				cell_data = VoxelEntry.new()
				cell_data.pos = Vector3i(
					i % data.width,
					floori(float(i) / data.width), # Warning: Integer division. Decimal part will be discarded.
					layer,
				)
				cell_data.color = Color.WHITE
				if cell_index < data.cells.size():
					data.cells[cell_index] = cell_data
				else:
					data.cells.append(cell_data)

	# Create color picker buttons for the current layer.
	for i in range(layer_cells):
		var cell_index := _get_cell_index(i)
		if cell_index >= data.cells.size():
			continue

		var cell_data := data.cells[cell_index]
		var btn := CustomColorPicker.new()
		btn.color = cell_data.color

		grid.add_child(btn)
		btn.size_flags_vertical = Control.SIZE_EXPAND_FILL
		btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL


func _update_layer_cells(_layer: int) -> void:
	for i in range(layer_cells):
		var cell_index = _get_cell_index(i)
		if cell_index < data.cells.size():
			var cell_data = data.cells[cell_index]
			var btn = grid.get_child(i) as CustomColorPicker
			btn.color = cell_data.color


func _get_cell_index(i: int) -> int:
	var layer_index := clampi(int(current_layer.value), 0, max(0, data.layers - 1))
	return layer_index * layer_cells + i


func _get_configuration_warnings() -> PackedStringArray:
	var warnings: PackedStringArray = []

	if data == null:
		warnings.append("VoxelEditorConfig must be assigned to 'data'.")

	return warnings
