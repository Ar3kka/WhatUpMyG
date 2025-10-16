class_name Hands extends Node3D

const DRAG_STRENGTH : float = 17.5
const ROTATION_STRENGTH : float = 3.5
const RAYCAST_DISTANCE : float = 250.0
const FINGER_SIZE : float = 0.5

@export var manipulator : Manipulator
@export var holding_drag : bool = true
@export var drag_strength : float = DRAG_STRENGTH
@export var manual_rotation_strength : float = ROTATION_STRENGTH
var mouse_position : Vector2 :
	set(new_value) : return
	get() : return get_viewport().get_mouse_position()
var finger : Area3D
@export var finger_size : float = FINGER_SIZE :
	set(new_finger_size):
		if finger == null : return
		finger_size = new_finger_size
		finger.scale = Vector3(finger_size, finger_size, finger_size)
		

var detected_object : Piece
var last_lookable_object : Piece
var lookable_object : Piece
var selectable_object : Piece
var selected_object : Piece
var draggable_object : Piece

var vertical_drag : bool = false
var horizontal_drag : bool = false
var rotate_left : bool = false
var rotate_right : bool = false

func _ready() -> void:
	if !manipulator : manipulator = get_parent_node_3d()
	finger = %Finger
	finger_size = FINGER_SIZE

func stop_dragging(draggable_component : DraggableComponent) :
	if !draggable_component : return
	if draggable_component.dragged(): draggable_component.stop_dragging()
	if !dragging(): return
	horizontal_drag = false
	vertical_drag = false

func _deselect():
	if !selected_object : return
	selected_object.selectable_component.select.emit(false, manipulator)
	var draggable_component : DraggableComponent = selected_object.draggable_component
	if draggable_component != null && draggable_component.active && draggable_component.dragged(): stop_dragging(draggable_component)
	selected_object = null

func dragging() -> bool: return horizontal_drag || vertical_drag

func double_drag() -> bool: return horizontal_drag && vertical_drag

func _process(_delta):
	if !manipulator || !manipulator.eyes: return
	
	var camera : Eyes = manipulator.eyes
	var team = manipulator.team
	
	###### RAYCAST
	camera.blink()
	
	###### SWITCH DRAGGING TYPE
	if Input.is_action_just_pressed("Switch Drag Mode"): holding_drag = !holding_drag
	
	###### DETECT LOOKABLE, SELECTABLE AND DRAGGABLE OBJECT
	var looked_at_nothing : bool = true
	if !dragging(): detected_object = camera.potential_momma
	
	if detected_object != null:
		looked_at_nothing = false
		# Detect lookable object
		var lookable_component : LookableComponent = detected_object.lookable_component
		if lookable_component == null || !lookable_component.active: return
		else:
			lookable_object = detected_object
			last_lookable_object = lookable_object
			if !lookable_component.looked_at: lookable_component.look.emit(true, manipulator)
		# Detect selectable object in case there's no drag
		if !dragging():
			var selectable_component : SelectableComponent = lookable_object.selectable_component
			if selectable_component && selectable_component.active: selectable_object = lookable_object
	else: if lookable_object != null: 
			# in case there is no detected object and there was a lookable object:
			# let the lookable object know that it's not being looked at anymore and reset object variables
			lookable_object.lookable_component.look.emit(false, manipulator)
			lookable_object = null
			detected_object = null
			selectable_object = null
			draggable_object = null
	
	# if the object IS NOT selectable and there's not an object already selected, skip
	if selectable_object == null && selected_object == null || lookable_object == null && last_lookable_object == null: return
	
	###### Checking selection inputs
	if selectable_object:
		if Input.is_action_just_pressed("Select"):
			if selectable_object != selected_object: _deselect()
			selectable_object.selectable_component.select.emit(true, manipulator)
			selected_object = selectable_object
		
		# Checking if the selectable object IS draggable
	else: if selected_object && Input.is_action_just_pressed("Select") && looked_at_nothing: _deselect()
	
	# Checking if the object being looked at or selected IS draggable
	var draggable_component : DraggableComponent
	var final_draggable_object : Piece
	if !selected_object: 
		draggable_component = last_lookable_object.draggable_component
		final_draggable_object = last_lookable_object
	else: 
		draggable_component = selected_object.draggable_component
		final_draggable_object = selected_object
	
	if draggable_component && draggable_component.active: 
		camera.big_momma = draggable_component
		draggable_object = final_draggable_object
	
	if Input.is_action_just_pressed("Deselect"): return _deselect()
	
	# if the object IS NOT draggable or if there's not an already selected object, skip
	if draggable_object == null || (selected_object != null && selected_object != draggable_object): return
	
	# Detect if object is in your team in order to interact with it:
	var team_component : TeamComponent = draggable_object.team_component
	if team_component != null: team_component.observer_team = team # set observing player team id to the team component
	# if there's a team component and it's active and the team id of the obj is above 0 
	# and the team id of the obj is different from your team, skip
	if team_component != null && team_component.active && team_component.team > 0 && team_component.team != team : return
	
	if selected_object == null: return
	
	####### Checking inputs to manually rotate the SELECTED object
	var rotatable_component : RotatableComponent = selected_object.rotatable_component
	if rotatable_component != null:
		if Input.is_action_just_pressed("Rotate Left"): rotatable_component.rotate.emit(Vector3(0, 1, 0), manipulator)
		else: if Input.is_action_just_pressed("Rotate Right"): rotatable_component.rotate.emit(Vector3(0, -1, 0), manipulator)
		if Input.is_action_just_released("Rotate Left") || Input.is_action_just_released("Rotate Right"): rotatable_component.stop_rotating()
	
	####### Checking drag inputs
	if Input.is_action_just_pressed("Drag Vertical"):
		if holding_drag || (!holding_drag && !vertical_drag) : vertical_drag = true
		else: vertical_drag = false
	if Input.is_action_just_pressed("Drag Horizontal"): 
		if holding_drag || (!holding_drag && !horizontal_drag) : horizontal_drag = true
		else: horizontal_drag = false
	
	####### Checking undragging inputs
	# checking if the object is still being dragged
	if holding_drag:
		if !Input.is_action_pressed("Drag Vertical"): vertical_drag = false
		if !Input.is_action_pressed("Drag Horizontal"): horizontal_drag = false
	
	####### RECOVER DRAG OBJECT INPUTS
	if Input.is_action_pressed("Recover") && !dragging(): vertical_drag = true
	
	var playable_component : PlayableComponent = selected_object.playable_component
	if (Input.is_action_pressed("Recover Playable") || playable_component.attacking_snap ) && !dragging() : 
		if playable_component && playable_component.being_played : 
			playable_component.reset_to_playable_position()
			return
	
	if !dragging(): return stop_dragging(draggable_component) # If no dragging action is recorded, we stop dragging.
	
	####### Calculating the position where the SELECTED object needs to move at
	
	finger.global_position = camera.sight
	
	var snappable_component : SnappableComponent = draggable_object.snappable_component
	if snappable_component && snappable_component.active && snappable_component.snapping:
		return
	
	# Emitting signal for the draggable, selected object to start being dragged towards the mouse position
	draggable_component.drag.emit(horizontal_drag, vertical_drag, camera.sight, drag_strength, manipulator)
	
