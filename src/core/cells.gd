extends RefCounted
class_name VoxelCells
## Encapsulates layer and cell operations for a VoxelModel.


var _model: VoxelModel
var _copied_layer_index: int = -1


func _init(model: VoxelModel) -> void:
	_model = model


func layer_cells_count() -> int:
	return _model.width * _model.height


func clamp_layer(layer_index: int) -> int:
	return clampi(layer_index, 0, max(0, _model.layers - 1))


func cell_index(layer_index: int, i: int) -> int:
	return clamp_layer(layer_index) * layer_cells_count() + i


func ensure_initialized() -> void:
	for layer in range(_model.layers):
		for i in range(layer_cells_count()):
			var index := cell_index(layer, i)
			var entry = _model.cells[index] if index < _model.cells.size() else null
			if entry != null:
				continue

			entry = VoxelEntry.new()
			entry.pos = Vector3i(
				i % _model.width,
				floori(float(i) / _model.width),
				layer,
			)
			entry.color = Color.WHITE

			if index < _model.cells.size():
				_model.cells[index] = entry
			else:
				_model.cells.append(entry)


func get_color(layer_index: int, i: int) -> Color:
	var index := cell_index(layer_index, i)
	if index >= 0 and index < _model.cells.size() and _model.cells[index] != null:
		return _model.cells[index].color
	return Color.WHITE


func set_color(layer_index: int, i: int, color: Color) -> void:
	var index := cell_index(layer_index, i)
	if index >= 0 and index < _model.cells.size() and _model.cells[index] != null:
		_model.cells[index].color = color


func copy_layer(layer_index: int) -> void:
	_copied_layer_index = clamp_layer(layer_index)


func paste_to_layer(target_layer_index: int) -> bool:
	if _copied_layer_index < 0 or _copied_layer_index >= _model.layers:
		return false

	var target := clamp_layer(target_layer_index)
	for i in range(layer_cells_count()):
		set_color(target, i, get_color(_copied_layer_index, i))

	return true


func copied_layer_index() -> int:
	return _copied_layer_index
