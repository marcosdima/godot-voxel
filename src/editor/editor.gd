@tool
extends VBoxContainer
class_name VoxelEditor
## VoxelModel editor for Godot. Provides a UI for editing voxel models in the editor.


@export var model: VoxelModel
@export_group("UI Elements")
@export var grid: GridContainer
@export var current_layer: LayerPicker
@export var save_button: Button


var layer_cells: int:
	get():
		return model.width * model.height


func _ready() -> void:
	if not Engine.is_editor_hint():
		# Configure layer picker.
		current_layer.min_value = 0
		current_layer.max_value = model.layers - 1
		current_layer.value = clamp(
			current_layer.value,
			current_layer.min_value,
			current_layer.max_value,
		)
		current_layer.value_changed.connect(_update_layer_cells)

		# Set up save button.
		save_button.pressed.connect(_on_save_pressed)

		_build_grid()
		


func _build_grid() -> void:
	# Set grid columns to match the width of the voxel editor configuration.
	grid.columns = model.width

	# Ensure every [layer, x, y] entry exists at its exact array index.
	for layer in range(model.layers):
		for i in range(layer_cells):
			var cell_index := layer * layer_cells + i
			var cell_data = model.cells[cell_index] if cell_index < model.cells.size() else null
			if cell_data == null:
				cell_data = VoxelEntry.new()
				cell_data.pos = Vector3i(
					i % model.width,
					floori(float(i) / model.width), # Warning: Integer division. Decimal part will be discarded.
					layer,
				)
				cell_data.color = Color.WHITE
				if cell_index < model.cells.size():
					model.cells[cell_index] = cell_data
				else:
					model.cells.append(cell_data)

	# Create color picker buttons for the current layer.
	for i in range(layer_cells):
		var cell_index := _get_cell_index(i)
		if cell_index >= model.cells.size():
			continue

		var cell_data := model.cells[cell_index]
		var btn := CustomColorPicker.new()
		btn.color = cell_data.color
		btn.color_changed.connect(
			func(new_color: Color, visual_index: int = i):
				var actual_cell_index := _get_cell_index(visual_index)
				if actual_cell_index < model.cells.size():
					model.cells[actual_cell_index].color = new_color
		)

		grid.add_child(btn)
		btn.size_flags_vertical = Control.SIZE_EXPAND_FILL
		btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL


func _update_layer_cells(_layer: int) -> void:
	for i in range(layer_cells):
		var cell_index = _get_cell_index(i)
		if cell_index < model.cells.size():
			var cell_data = model.cells[cell_index]
			var btn = grid.get_child(i) as CustomColorPicker
			btn.color = cell_data.color


func _get_cell_index(i: int) -> int:
	var layer_index := clampi(int(current_layer.value), 0, max(0, model.layers - 1))
	return layer_index * layer_cells + i


func _get_configuration_warnings() -> PackedStringArray:
	var warnings: PackedStringArray = []

	if model == null:
		warnings.append("VoxelEditorConfig must be assigned to 'model'.")

	return warnings


func _on_save_pressed() -> void:
	var save_path := model.resource_path
	var err := ResourceSaver.save(model, save_path)

	if err != OK:
		push_error("Failed to save VoxelEditorConfig to %s (error %d)." % [save_path, err])
		return

	print("VoxelEditorConfig saved to %s" % save_path)
