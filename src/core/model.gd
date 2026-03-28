extends Resource
class_name VoxelModel
## Represents a voxel model composed of editable voxel entries.


## The width of each layer in the voxel model.
@export var width: int = 5

## The height of each layer in the voxel model.
@export var height: int = 5

## Number of layers in the voxel model.
@export var layers: int = 1

## Editable list of voxel entries used for authoring.
@export var cells: Array[VoxelEntry] = []

## Cached mesh generated from voxel data.
var _mesh: ArrayMesh


## Returns the cached mesh or builds it if not available.
func get_mesh() -> ArrayMesh:
	if _mesh == null:
		var dict := _to_dict()
		_mesh = VoxelMeshBuilder.build(dict)
	return _mesh


## Converts voxel entries into a dictionary for fast lookup.
func _to_dict() -> Dictionary[Vector3i, Color]:
	var d: Dictionary[Vector3i, Color] = {}
	var layer_cell_count := width * height

	for index in range(cells.size()):
		var e := cells[index]
		if e == null:
			continue

		# Transparent voxels are treated as empty cells.
		if e.color.a <= 0.0:
			continue

		var layer_index := floori(float(index) / layer_cell_count)
		var cell_offset := index % layer_cell_count
		var row := floori(float(cell_offset) / width)
		var pos := Vector3i(
			cell_offset % width,
			height - 1 - row,
			layer_index,
		)

		# Check for duplicate positions to avoid overwriting colors.
		if d.has(pos):
			push_warning("Duplicate voxel at position %s." % [pos])

		d[pos] = e.color

	return d


## Invalidates the cached mesh forcing a rebuild.
func invalidate():
	_mesh = null
