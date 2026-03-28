extends VBoxContainer
class_name VoxelEditor
## VoxelModel editor for Godot. Provides a UI for editing voxel models in the editor.


## Voxel model resource edited through this UI.
@export var model: VoxelModel

@export_group("UI Elements")

## Grid container used to display cell buttons.
@export var grid: GridContainer

## Layer picker used to select the active layer.
@export var current_layer: LayerPicker

## Save button that writes model data to disk.
@export var save_button: Button

## Copy button that stores the currently selected layer.
@export var copy_button: Button

## Paste button that applies copied data into the current layer.
@export var paste_button: Button


## Core helper that manages layer and cell operations.
var cells: VoxelCells


## Number of editable cells for one layer.
var layer_cells: int:
	get():
		if model == null:
			return 0

		if cells != null:
			return cells.layer_cells_count

		return model.width * model.height


func _ready() -> void:
	if not _validate_required_references():
		return

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
	cells.ensure_layer_initialized(int(current_layer.value))

	# Set up save button.
	save_button.pressed.connect(_on_save_pressed)
	if copy_button != null:
		copy_button.pressed.connect(_on_copy_pressed)

	if paste_button != null:
		paste_button.pressed.connect(_on_paste_pressed)

	_build_grid()


## Validates required references before the editor is initialized.
func _validate_required_references() -> bool:
	if model == null:
		push_error("VoxelEditor requires 'model' to be assigned.")
		return false

	if grid == null:
		push_error("VoxelEditor requires 'grid' to be assigned.")
		return false

	if current_layer == null:
		push_error("VoxelEditor requires 'current_layer' to be assigned.")
		return false

	if save_button == null:
		push_error("VoxelEditor requires 'save_button' to be assigned.")
		return false

	return true


## Builds the visual grid for the active layer.
func _build_grid() -> void:
	# Set grid columns to match the width of the voxel editor configuration.
	grid.columns = model.width
	cells.ensure_layer_initialized(int(current_layer.value))

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


## Updates button colors when layer selection changes.
func _update_layer_cells(_layer: int) -> void:
	cells.ensure_layer_initialized(int(current_layer.value))

	for i in range(layer_cells):
		var btn = grid.get_child(i) as CustomColorPicker
		btn.color = cells.get_color(int(current_layer.value), i)


## Copies the currently selected layer.
func _on_copy_pressed() -> void:
	if cells == null:
		push_error("VoxelEditor cells helper is not initialized.")
		return

	cells.copy_layer(int(current_layer.value))
	print("Layer %d copied" % cells.copied_layer_index())


## Pastes the copied layer into the currently selected layer.
func _on_paste_pressed() -> void:
	if cells == null:
		push_error("VoxelEditor cells helper is not initialized.")
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

	if grid == null:
		warnings.append("Grid must be assigned to 'grid'.")

	if current_layer == null:
		warnings.append("Layer picker must be assigned to 'current_layer'.")

	if save_button == null:
		warnings.append("Save button must be assigned to 'save_button'.")

	if copy_button == null:
		warnings.append("Copy button must be assigned to 'copy_button'.")

	if paste_button == null:
		warnings.append("Paste button must be assigned to 'paste_button'.")

	return warnings


## Saves the model resource to its current path.
func _on_save_pressed() -> void:
	var save_path := model.resource_path
	var err := ResourceSaver.save(model, save_path)

	if err != OK:
		push_error("Failed to save VoxelEditorConfig to %s (error %d)." % [save_path, err])
		return

	print("VoxelEditorConfig saved to %s" % save_path)
