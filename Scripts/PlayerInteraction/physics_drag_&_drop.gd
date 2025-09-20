extends Node3D

@onready var raycast := $DraggableRay
@export var camera : Camera3D
@export var rotation_strenght := 300.0
@export var drag_rotation_strength := 0.05
@export var drag_strength := 0.1
var raycast_distance := 250.0

var mouse_position : Vector2
var detected_object : RigidBody3D
var draggable_object : RigidBody3D
var selected_object : RigidBody3D
var on_drag_position_state : Vector3
var vertical_drag := false
var horizontal_drag := false
var rotate_left := false
var rotate_right := false

func _process(delta):
	###### Raycast
	mouse_position = get_viewport().get_mouse_position()
	raycast.target_position = camera.project_local_ray_normal(mouse_position) * raycast_distance
	raycast.force_raycast_update()
	
	###### Detect draggable object
	detected_object = raycast.get_collider()
	if raycast.is_colliding() && detected_object.get_node("Draggable"): draggable_object = detected_object
	
	# if the object IS NOT draggable, skip
	if !draggable_object: return
	
	# if the object IS draggable, freeze it
	
	####### Checking drag inputs
	#if Input.is_action_pressed("Drag Vertical"): vertical_drag = true
	if Input.is_action_just_pressed("Drag Vertical"): 
		selected_object = draggable_object
		selected_object.get_node("Draggable").start_dragging()
		print(selected_object)
	
	####### Checking deselection inputs
	# checking if the object is still being dragged
	if (Input.is_action_just_released("Drag Vertical")) || !selected_object: 
		# if the object is not being dragged anymore, we discard the draggable object and skip the dragging process
		if selected_object != null: selected_object.get_node("Draggable").stop_dragging()
		draggable_object = null
		selected_object = null
		#if draggable_object.get_node("Mesh/Outline") != null && detected_object != null: draggable_object.get_node("Mesh/Outline").visible = true
		return
	
	####### Checking inputs to manually rotate the SELECTED object
	if Input.is_action_pressed("Rotate Left"): selected_object.rotation_degrees.y -= rotation_strenght * delta
	else: if Input.is_action_pressed("Rotate Right"): selected_object.rotation_degrees.y += rotation_strenght * delta
	if Input.is_action_just_released("Rotate Left"): selected_object.rotation_degrees.y = selected_object.rotation_degrees.y - 10 * delta
	
	####### Calculating the position where the SELECTED object needs to move at
	var ray_origin = camera.project_ray_origin(mouse_position)
	var ray_end = camera.project_ray_normal(mouse_position)
	var ray_depth = ray_origin.distance_to(on_drag_position_state)
	var final_ray_position = ray_origin + ray_end * ray_depth
	var final_drag_position = Vector2(final_ray_position.y, final_ray_position.z)
	# Check if the object is being dragged in both axis
	# Rotating, and moving the SELECTED object towards the mouse pointer
	
	selected_object.get_node("Draggable").process_dragging(final_ray_position)
