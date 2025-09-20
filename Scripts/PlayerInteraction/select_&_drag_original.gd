extends Node3D

@export var camera : Camera3D
@export var rotation_strenght : float = 300.0
@export var drag_rotation_strength : float = 0.05
@export var drag_strength : float = 0.1
var raycast : RayCast3D
@export var raycast_distance : float = 250.0

var mouse_position : Vector2
var detected_object : RigidBody3D
var draggable_object : RigidBody3D
var selected_object : RigidBody3D
#var on_drag_position_state : Vector3
var vertical_drag : bool = false
var horizontal_drag : bool = false
var rotate_left : bool = false
var rotate_right : bool = false

func _ready() -> void:
	raycast = RayCast3D.new()
	add_child(raycast)
	
func _dragging() -> bool: return horizontal_drag || vertical_drag

func _double_drag() -> bool: return horizontal_drag && vertical_drag

func _process(delta):
	###### Raycast
	mouse_position = get_viewport().get_mouse_position()
	raycast.target_position = camera.project_local_ray_normal(mouse_position) * raycast_distance
	raycast.force_raycast_update()
	
	###### Detect draggable object
	detected_object = raycast.get_collider()
	if detected_object != null && !_dragging(): 
		var draggable_component : DraggableComponent = detected_object.get_node("Draggable")
		if draggable_component && draggable_component.active: draggable_object = detected_object
	
	# if the object IS NOT draggable, skip
	if !draggable_object: return
	
	# if the object IS draggable, freeze it
	draggable_object.freeze = true
	draggable_object.freeze_mode = RigidBody3D.FREEZE_MODE_KINEMATIC
	
	####### Checking drag inputs
	if Input.is_action_pressed("Drag Vertical"): vertical_drag = true
	if Input.is_action_pressed("Drag Horizontal"): horizontal_drag = true
	
	# if draggable object is dragged, select it
	if horizontal_drag || vertical_drag: selected_object = draggable_object
	
	# save initial dragged object state
	#if selected_object == draggable_object: on_drag_position_state = selected_object.global_position
	
	####### Checking deselection inputs
	# checking if the object is still being dragged
	if (Input.is_action_just_released("Drag Vertical") || Input.is_action_just_released("Drag Horizontal")) || !selected_object: 
		# if the object is not being dragged anymore, we discard the draggable object and skip the dragging process
		selected_object = null
		horizontal_drag = false
		vertical_drag = false
		draggable_object.freeze = false
		draggable_object = null
		#if draggable_object.get_node("Mesh/Outline") != null && detected_object != null: draggable_object.get_node("Mesh/Outline").visible = true
		return
	
	####### Checking inputs to manually rotate the SELECTED object
	if Input.is_action_pressed("Rotate Left"): selected_object.rotation_degrees.y -= rotation_strenght * delta
	else: if Input.is_action_pressed("Rotate Right"): selected_object.rotation_degrees.y += rotation_strenght * delta
	if Input.is_action_just_released("Rotate Left"): selected_object.rotation_degrees.y = selected_object.rotation_degrees.y - 10 * delta
	
	####### Calculating the position where the SELECTED object needs to move at
	var ray_origin = camera.project_ray_origin(mouse_position)
	var ray_end = camera.project_ray_normal(mouse_position)
	var ray_depth = ray_origin.distance_to(selected_object.global_position)
	var final_ray_position = ray_origin + ray_end * ray_depth
	var final_drag_position = Vector2(final_ray_position.y, final_ray_position.z)
	# Check if the object is being dragged in both axis
	if !_double_drag():
		if vertical_drag: final_drag_position.x = selected_object.global_position.y
		if horizontal_drag: final_drag_position.y = selected_object.global_position.z
	# Check if the y axis is not below ground level, if it is, set it to 0 to prevent dragging out of the worldmap
	if final_drag_position.x < 0.0 : final_drag_position.x = 0.0
	# Rotating, and moving the SELECTED object towards the mouse pointer
	selected_object.global_position = lerp(selected_object.global_position, Vector3(final_ray_position.x, final_drag_position.x, final_drag_position.y), drag_strength)
	if selected_object.rotation_degrees != Vector3(0, selected_object.rotation_degrees.y, 0): selected_object.rotation_degrees = lerp(selected_object.rotation_degrees, Vector3(0, selected_object.rotation_degrees.y, 0), drag_rotation_strength)
	
