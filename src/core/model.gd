extends Resource
class_name VoxelModel
## Represents a voxel model composed of editable voxel entries.

## Editable list of voxel entries used for authoring.
@export var entries: Array[VoxelEntry]

## Cached mesh generated from voxel data.
var _mesh: ArrayMesh


## Returns the cached mesh or builds it if not available.
func get_mesh() -> ArrayMesh:
	if _mesh == null:
		var dict := _to_dict()
		_mesh = VoxelMeshBuilder.build(dict)
	return _mesh


## Converts voxel entries into a dictionary for fast lookup.
func _to_dict() -> Dictionary:
	var d := {}

	for e in entries:
		# Check for duplicate positions to avoid overwriting colors.
		if d.has(e.pos):
			push_warning("Duplicate voxel at position %s." % [e.pos])

		d[e.pos] = e.color

	return d


## Invalidates the cached mesh forcing a rebuild.
func invalidate():
	_mesh = null
