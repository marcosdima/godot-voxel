extends Node3D

@export var model: VoxelModel
@export var move_speed: float = 10.0
@export var mouse_sensitivity: float = 0.003

var camera: Camera3D


func _ready():
	if model == null:
		push_error("No VoxelModel assigned")
		return

	var mesh = model.get_mesh()
	
	var mesh_instance = MeshInstance3D.new()
	mesh_instance.mesh = mesh
	add_child(mesh_instance)
	
	# Add light
	var light = DirectionalLight3D.new()
	light.rotation = Vector3(-0.5, 0, 0)
	get_parent().add_child.call_deferred(light)
	
	# Find camera
	camera = get_parent().find_child("Camera3D", true, false) as Camera3D
	if camera:
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	else:
		push_error("No Camera3D found in parent!")


func _process(delta):
	if not camera:
		return
	
	# WASD movement using direct key input
	var input_dir = Vector3.ZERO
	if Input.is_key_pressed(KEY_D):
		input_dir.x += 1
	if Input.is_key_pressed(KEY_A):
		input_dir.x -= 1
	if Input.is_key_pressed(KEY_W):
		input_dir.z -= 1
	if Input.is_key_pressed(KEY_S):
		input_dir.z += 1
	
	if input_dir.length() > 0:
		input_dir = input_dir.normalized()
		var move_vec = camera.global_transform.basis * (input_dir * move_speed * delta)
		camera.global_position += move_vec
	
	# ESC to release mouse
	if Input.is_action_just_pressed("ui_cancel"):
		if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
			Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		else:
			Input.mouse_mode = Input.MOUSE_MODE_CAPTURED


func _input(event):
	if not camera or Input.mouse_mode != Input.MOUSE_MODE_CAPTURED:
		return
	
	if event is InputEventMouseMotion:
		var mouse_event = event as InputEventMouseMotion
		var rotation_yaw = -mouse_event.relative.x * mouse_sensitivity
		var rotation_pitch = -mouse_event.relative.y * mouse_sensitivity
		
		camera.rotate_y(rotation_yaw)
		camera.rotate_object_local(Vector3.RIGHT, rotation_pitch)
