extends Resource
class_name VoxelEntry
## Represents a single voxel definition used by voxel editors/builders.

## Grid position of the voxel in integer coordinates.
@export var pos: Vector3i
## Display color assigned to this voxel.
## Default is transparent (empty/unset voxel).
@export var color: Color = Color(0, 0, 0, 0)
