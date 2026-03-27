extends VBoxContainer
class_name VoxelEditor
## VoxelModel editor for Godot. Provides a UI for editing voxel models in the editor.


@export var model: VoxelModel
@export_group("UI Elements")
@export var grid: GridContainer
@export var current_layer: LayerPicker
@export var save_button: Button
@export var copy_button: Button
@export var paste_button: Button


var cells: VoxelCells


var layer_cells: int:
	get():
		if cells != null:
			return cells.layer_cells_count()
		return model.width * model.height


func _ready() -> void:
	# Configure layer picker.
	current_layer.min_value = 0
	current_layer.max_value = model.layers - 1
	current_layer.value = clamp(
		current_layer.value,
		current_layer.min_value,
		current_layer.max_value,
	)
	current_layer.value_changed.connect(_update_layer_cells)

	cells = VoxelCells.new(model)
	cells.ensure_initialized()

	# Set up save button.
	save_button.pressed.connect(_on_save_pressed)
	if copy_button != null:
		copy_button.pressed.connect(_on_copy_pressed)
	if paste_button != null:
		paste_button.pressed.connect(_on_paste_pressed)

	_build_grid()
		

func _build_grid() -> void:
	# Set grid columns to match the width of the voxel editor configuration.
	grid.columns = model.width

	# Create color picker buttons for the current layer.
	for i in range(layer_cells):
		var btn := CustomColorPicker.new()
		btn.color = cells.get_color(int(current_layer.value), i)
		btn.color_changed.connect(
			func(new_color: Color, visual_index: int = i):
				cells.set_color(int(current_layer.value), visual_index, new_color)
		)

		grid.add_child(btn)
		btn.size_flags_vertical = Control.SIZE_EXPAND_FILL
		btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL


func _update_layer_cells(_layer: int) -> void:
	for i in range(layer_cells):
		var btn = grid.get_child(i) as CustomColorPicker
		btn.color = cells.get_color(int(current_layer.value), i)


func _on_copy_pressed() -> void:
	if cells == null:
		return

	cells.copy_layer(int(current_layer.value))
	print("Layer %d copied" % cells.copied_layer_index())


func _on_paste_pressed() -> void:
	if cells == null:
		return

	if not cells.paste_to_layer(int(current_layer.value)):
		push_warning("No layer copied yet.")
		return

	var target_layer_index := int(current_layer.value)
	_update_layer_cells(target_layer_index)
	print("Layer %d pasted into layer %d" % [cells.copied_layer_index(), target_layer_index])


func _get_configuration_warnings() -> PackedStringArray:
	var warnings: PackedStringArray = []

	if model == null:
		warnings.append("VoxelEditorConfig must be assigned to 'model'.")
	if current_layer == null:
		warnings.append("Layer picker must be assigned to 'current_layer'.")
	if copy_button == null:
		warnings.append("Copy button must be assigned to 'copy_button'.")
	if paste_button == null:
		warnings.append("Paste button must be assigned to 'paste_button'.")

	return warnings


func _on_save_pressed() -> void:
	var save_path := model.resource_path
	var err := ResourceSaver.save(model, save_path)

	if err != OK:
		push_error("Failed to save VoxelEditorConfig to %s (error %d)." % [save_path, err])
		return

	print("VoxelEditorConfig saved to %s" % save_path)
