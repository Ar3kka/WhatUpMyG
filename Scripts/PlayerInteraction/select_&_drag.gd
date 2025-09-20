extends Node3D

@export var camera : Camera3D
@export var rotation_strenght : float = 300.0
@export var drag_strength : float = 0.1
var raycast : RayCast3D
@export var raycast_distance : float = 250.0
var mouse_position : Vector2

var detected_object : RigidBody3D
var lookable_object : LookableComponent :
	set(new_object):
		print(new_object)
		if new_object == null: 
			lookable_object.look.emit(false)
		lookable_object = new_object
var draggable_object : RigidBody3D
var selected_object : RigidBody3D

var vertical_drag : bool = false
var horizontal_drag : bool = false
var rotate_left : bool = false
var rotate_right : bool = false

func _ready() -> void:
	raycast = RayCast3D.new()
	add_child(raycast)

func stop_dragging() :
	# if the object is not being dragged anymore, 
	# we discard the draggable object and skip the dragging process
	horizontal_drag = false
	vertical_drag = false
	
	if draggable_object != null: draggable_object.freeze = false
	draggable_object = null
	selected_object = null

func dragging() -> bool: return horizontal_drag || vertical_drag

func double_drag() -> bool: return horizontal_drag && vertical_drag

func _process(delta):
	###### Raycast
	mouse_position = get_viewport().get_mouse_position()
	raycast.target_position = camera.project_local_ray_normal(mouse_position) * raycast_distance
	raycast.force_raycast_update()
	
	###### Detect draggable object
	detected_object = raycast.get_collider()
	if detected_object != null && !dragging():
		#lookable_object = detected_object.get_node("Lookable")
		#if lookable_object == null: return
		var draggable_component : DraggableComponent = detected_object.get_node("Draggable")
		if draggable_component && draggable_component.active: 
			draggable_object = detected_object
			#lookable_object.look.emit(true)
	
	# if the object IS NOT draggable, skip
	if !draggable_object: return
	
	# if the object IS draggable, freeze it
	draggable_object.freeze = true
	draggable_object.freeze_mode = RigidBody3D.FREEZE_MODE_KINEMATIC
	
	####### Checking drag inputs
	if Input.is_action_pressed("Drag Vertical"): vertical_drag = true
	if Input.is_action_pressed("Drag Horizontal"): horizontal_drag = true
	
	var draggable_component : DraggableComponent
	
	# if draggable object is being dragged, select it
	if dragging(): 
		selected_object = draggable_object
		draggable_component = selected_object.get_node("Draggable")
	
	####### Checking deselection inputs
	# checking if the object is still being dragged
	if (Input.is_action_just_released("Drag Vertical") || Input.is_action_just_released("Drag Horizontal")) || !selected_object:
		# If no dragging action is recorded, we stop dragging.
		if dragging() : draggable_component.stop_dragging()
		stop_dragging()
		return
	
	####### Checking inputs to manually rotate the SELECTED object
	if Input.is_action_pressed("Rotate Left"): selected_object.rotation_degrees.y -= rotation_strenght * delta
	else: if Input.is_action_pressed("Rotate Right"): selected_object.rotation_degrees.y += rotation_strenght * delta
	if Input.is_action_just_released("Rotate Left"): selected_object.rotation_degrees.y = selected_object.rotation_degrees.y * delta
	
	####### Calculating the position where the SELECTED object needs to move at
	var ray_origin = camera.project_ray_origin(mouse_position)
	var ray_end = camera.project_ray_normal(mouse_position)
	var ray_depth = ray_origin.distance_to(draggable_component.body_position)
	var final_ray_position = ray_origin + ray_end * ray_depth

	draggable_component.drag.emit(horizontal_drag, vertical_drag, final_ray_position, drag_strength)
	#if selected_object.rotation_degrees != Vector3(0, selected_object.rotation_degrees.y, 0): selected_object.rotation_degrees = lerp(selected_object.rotation_degrees, Vector3(0, selected_object.rotation_degrees.y, 0), drag_rotation_strength)
