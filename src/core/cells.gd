extends RefCounted
class_name VoxelCells
## Encapsulates layer and cell operations for a VoxelModel.


## Backing model resource edited through this helper.
var _model: VoxelModel

## Stores the last copied layer index, or -1 if nothing was copied yet.
var _copied_layer_index: int = -1

## Layer and cell counts based on the model dimensions.
var layer_cells_count: int:
	get():
		return _model.width * _model.height

## Total expected cells across all layers based on model dimensions.
var expected_cells_count: int:
	get():
		return layer_cells_count * _model.layers


func _init(model: VoxelModel) -> void:
	_model = model


## Ensures one layer has all required cell entries initialized.
## Returns true when the layer is valid and initialized.
func ensure_layer_initialized(layer_index: int) -> bool:
	if not _is_valid_layer_index(layer_index):
		return false

	# Grow the array so this layer can be fully addressed by index.
	var required_cells := (layer_index + 1) * layer_cells_count
	if _model.cells.size() < required_cells:
		_model.cells.resize(required_cells)

	for i in range(layer_cells_count):
		var index := layer_index * layer_cells_count + i

		# Skip already initialized cells to preserve existing colors.
		if _model.cells[index] != null:
			continue

		# Initialize missing cells with deterministic position and default color.
		var entry := VoxelEntry.new()
		var row := floori(float(i) / _model.width)
		entry.pos = Vector3i(
			i % _model.width,
			_model.height - 1 - row,
			layer_index,
		)
		entry.color = Color(0, 0, 0, 0)
		_model.cells[index] = entry

	return true


## Returns the color for a layer cell, or transparent when invalid/unavailable.
func get_color(layer_index: int, i: int) -> Color:
	if not _ensure_valid_cell(layer_index, i):
		return Color(0, 0, 0, 0)

	var index := layer_index * layer_cells_count + i
	if _model.cells[index] != null:
		return _model.cells[index].color
		
	return Color(0, 0, 0, 0)


## Sets the color for one layer cell.
func set_color(layer_index: int, i: int, color: Color) -> void:
	if not _ensure_valid_cell(layer_index, i):
		return

	var index := layer_index * layer_cells_count + i
	_model.cells[index].color = color


## Copies the source layer index for a later paste operation.
func copy_layer(layer_index: int) -> void:
	if not _ensure_valid_cell(layer_index):
		return

	_copied_layer_index = layer_index


## Pastes copied colors into the target layer.
## Returns true on success, false when copy/target state is invalid.
func paste_to_layer(target_layer_index: int) -> bool:
	# A copied layer must exist before a paste can happen.
	if _copied_layer_index < 0:
		push_warning("No copied layer available.")
		return false

	# Validate and ensure both layers are initialized.
	if not _ensure_valid_cell(_copied_layer_index):
		return false
	if not _ensure_valid_cell(target_layer_index):
		return false

	# Copy each cell color from source layer to target layer.
	for i in range(layer_cells_count):
		var source_index := _copied_layer_index * layer_cells_count + i
		var target_index := target_layer_index * layer_cells_count + i
		_model.cells[target_index].color = _model.cells[source_index].color

	return true


## Returns the currently copied layer index, or -1 if none.
func copied_layer_index() -> int:
	return _copied_layer_index


## Returns true when layer index is within model bounds.
func _is_valid_layer_index(layer_index: int) -> bool:
	var is_valid_layer := layer_index >= 0 and layer_index < _model.layers
	if not is_valid_layer:
		push_error("Layer index %d is out of bounds (0 to %d)." % [layer_index, _model.layers - 1])
	return is_valid_layer


## Validates and ensures a layer/cell are valid and initialized.
func _ensure_valid_cell(layer_index: int, cell_offset: int = -1) -> bool:
	# Validate layer index (reports error if invalid).
	if not _is_valid_layer_index(layer_index):
		return false

	# Validate cell offset if provided.
	if cell_offset >= 0:
		if not (cell_offset >= 0 and cell_offset < layer_cells_count):
			push_error("Cell offset %d is out of bounds (0 to %d)." % [cell_offset, layer_cells_count - 1])
			return false

	# Ensure layer is initialized.
	if not ensure_layer_initialized(layer_index):
		return false

	return true
