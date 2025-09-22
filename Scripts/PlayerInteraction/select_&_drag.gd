extends Node3D

@export var camera : Camera3D
@export var team : int = 0
@export var rotation_strenght : float = 300.0
@export var drag_strength : float = 0.1
var raycast : RayCast3D
@export var raycast_distance : float = 250.0
var mouse_position : Vector2

var detected_object : RigidBody3D
var lookable_object : RigidBody3D
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
	selected_object = null
	draggable_object = null

func _reset_objects():
	detected_object = null
	lookable_object = null
	draggable_object = null
	selected_object = null

func dragging() -> bool: return horizontal_drag || vertical_drag

func double_drag() -> bool: return horizontal_drag && vertical_drag

func _process(_delta):
	###### Raycast
	mouse_position = get_viewport().get_mouse_position()
	raycast.target_position = camera.project_local_ray_normal(mouse_position) * raycast_distance
	raycast.force_raycast_update()
	
	###### Detect draggable object
	if selected_object == null && !dragging(): 
		detected_object = raycast.get_collider()
	if detected_object != null:
		var lookable_component : LookableComponent = detected_object.get_node("Lookable")
		if lookable_component == null || !lookable_component.active: return
		else:
			lookable_object = detected_object
			if !lookable_component.looked_at: lookable_component.look.emit(true)
		if !dragging():
			var draggable_component : DraggableComponent = lookable_object.get_node("Draggable")
			if draggable_component && draggable_component.active: draggable_object = lookable_object
	else: if lookable_object != null:
		lookable_object.get_node("Lookable").look.emit(false)
		_reset_objects()
	# if the object IS NOT draggable, skip
	if draggable_object == null && selected_object == null: return
	
	####### Checking drag inputs
	if Input.is_action_pressed("Drag Vertical"): vertical_drag = true
	if Input.is_action_pressed("Drag Horizontal"): horizontal_drag = true
	
	# if draggable object is being dragged, if not, skip
	if !dragging(): return 
	
	var draggable_component : DraggableComponent
	selected_object = draggable_object
	draggable_component = selected_object.get_node("Draggable")
	
	####### Checking deselection inputs
	# checking if the object is still being dragged
	if Input.is_action_just_released("Drag Vertical") || Input.is_action_just_released("Drag Horizontal"):
		# If no dragging action is recorded, we stop dragging.
		draggable_component.stop_dragging()
		stop_dragging()
		return
	
	####### Checking inputs to manually rotate the SELECTED object
	#if Input.is_action_pressed("Rotate Left"): selected_object.rotation_degrees.y -= rotation_strenght * delta
	#else: if Input.is_action_pressed("Rotate Right"): selected_object.rotation_degrees.y += rotation_strenght * delta
	#if Input.is_action_just_released("Rotate Left"): selected_object.rotation_degrees.y = selected_object.rotation_degrees.y * delta
	
	####### Calculating the position where the SELECTED object needs to move at
	var ray_origin = camera.project_ray_origin(mouse_position)
	var ray_end = camera.project_ray_normal(mouse_position)
	var ray_depth = ray_origin.distance_to(draggable_component.body_position)
	var final_ray_position = ray_origin + ray_end * ray_depth
	
	# Emitting signal for the draggable, selected object to start being dragged towards the mouse position
	draggable_component.drag.emit(horizontal_drag, vertical_drag, final_ray_position, drag_strength)
