extends Node3D
class_name VoxelMeshBuilder
## Static builder responsible for generating meshes from voxel data.

## Directions used to check voxel neighbors.
const dirs: Array[Vector3i] = [
	Vector3i(1,0,0),
	Vector3i(-1,0,0),
	Vector3i(0,1,0),
	Vector3i(0,-1,0),
	Vector3i(0,0,1),
	Vector3i(0,0,-1),
]

## Builds a mesh from a voxel dictionary.
## *Only visible faces are generated.
static func build(voxels: Dictionary[Vector3i, Color], size: float = 1.0) -> ArrayMesh:
	var st = SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)

	## Iterate through all voxels.
	for pos in voxels.keys() as Array[Vector3i]:
		var color := voxels[pos]

		## Check each direction and generate faces if needed.
		for dir in dirs:
			var neighbor := pos + dir

			## Only generate face if no adjacent voxel exists.
			if not voxels.has(neighbor):
				_add_face(st, pos, dir, size, color)

	st.generate_normals()

	var mesh = st.commit()

	## Assign material that uses vertex colors.
	var material = StandardMaterial3D.new()
	material.vertex_color_use_as_albedo = true
	mesh.surface_set_material(0, material)

	return mesh


## Adds a single face for a voxel in the given direction.
static func _add_face(st: SurfaceTool, pos: Vector3i, dir: Vector3i, size: float, color: Color):
	## Half size of the voxel cube.
	var hs = size * 0.5

	## Converts voxel grid position into world position.
	var base = Vector3(pos) * size

	## Quad vertices for the face.
	var v0: Vector3
	var v1: Vector3
	var v2: Vector3
	var v3: Vector3

	## Defines the face geometry depending on direction.
	## Each block defines a quad oriented outwards.
	match dir:
		## Front face (+Z).
		Vector3i(0,0,1):
			v0 = base + Vector3(-hs,-hs, hs)
			v1 = base + Vector3( hs,-hs, hs)
			v2 = base + Vector3( hs, hs, hs)
			v3 = base + Vector3(-hs, hs, hs)

		## Back face (-Z).
		Vector3i(0,0,-1):
			v0 = base + Vector3( hs,-hs,-hs)
			v1 = base + Vector3(-hs,-hs,-hs)
			v2 = base + Vector3(-hs, hs,-hs)
			v3 = base + Vector3( hs, hs,-hs)

		## Left face (-X).
		Vector3i(-1,0,0):
			v0 = base + Vector3(-hs,-hs,-hs)
			v1 = base + Vector3(-hs,-hs, hs)
			v2 = base + Vector3(-hs, hs, hs)
			v3 = base + Vector3(-hs, hs,-hs)

		## Right face (+X).
		Vector3i(1,0,0):
			v0 = base + Vector3( hs,-hs, hs)
			v1 = base + Vector3( hs,-hs,-hs)
			v2 = base + Vector3( hs, hs,-hs)
			v3 = base + Vector3( hs, hs, hs)

		## Top face (+Y).
		Vector3i(0,1,0):
			v0 = base + Vector3(-hs, hs, hs)
			v1 = base + Vector3( hs, hs, hs)
			v2 = base + Vector3( hs, hs,-hs)
			v3 = base + Vector3(-hs, hs,-hs)

		## Bottom face (-Y).
		Vector3i(0,-1,0):
			v0 = base + Vector3(-hs,-hs,-hs)
			v1 = base + Vector3( hs,-hs,-hs)
			v2 = base + Vector3( hs,-hs, hs)
			v3 = base + Vector3(-hs,-hs, hs)

	## IMPORTANT: Vertex order defines triangle direction.
	## Godot expects counter-clockwise (CCW) winding for front faces.

	## First triangle of the quad.
	st.set_color(color)
	st.add_vertex(v0)
	st.add_vertex(v2)
	st.add_vertex(v1)

	## Second triangle of the quad.
	st.set_color(color)
	st.add_vertex(v0)
	st.add_vertex(v3)
	st.add_vertex(v2)
