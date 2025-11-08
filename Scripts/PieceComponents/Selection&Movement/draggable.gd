class_name DraggableComponent extends Node3D

signal drag(horizontal : bool, vertical : bool, target : Vector3, strength : float, player_requested_to_drag : Manipulator)
signal started_dragging()
signal stopped_dragging()

## RECOMMENDED SETTINGS
const ROTATION_STRENGTH : float = 0.05
const DRAGGING_STRENGTH : float = 14.5
const NOT_DRAGGING_LIMIT : float = 1.0
const STANDARD_DRAG_ANIMATION_FORCE : float = 15.0
const STANDARD_DRAG_ANIMATION_ROTATION : float = 10.0
const X_LIMIT : float = 0.0

var global := GeneralKnowledge.new()

## The piece this component belongs to.
@export var body : Piece
## Whether or not this piece is active and functional.
@export var active : bool = true
## Whether or not this tile is draggable by the means of manipulation (by a player with the mouse)
@export var manipulable : bool = true
var current_manipulator : Manipulator
var _manipulator_list : Array[Manipulator] = []
var being_manipulated : bool :
	set(new_value) : return
	get(): return _manipulator_list.size() > 0 || current_manipulator
@export_group("Reaction Settings")
## Freeze all physics interaction to kinematic when the piece is being dragged
@export var freeze : bool = true
## Fix the rotation by the standard rotation set in the rotatable component (only works if piece is rotatable)
@export var fix_rotation : bool = true
@export_group("Dragging Settings")
## The dragging strength for when this piece is being dragged
@export var dragging_strength : float = DRAGGING_STRENGTH
## Whether or not the individual drag strength set for each piece should be overwritten by the dragging
## strength of the manipulator
@export var override_drag_strength : bool = true
@export var drag_animation : bool = true
@export var drag_animation_force : float = STANDARD_DRAG_ANIMATION_FORCE
@export var drag_animation_rotation_distance : float = STANDARD_DRAG_ANIMATION_ROTATION
var _custom_dragging_strength : float
var _next_position : Vector3
var _stop_dragging_timer := Timer.new()

var horizontal_drag : bool = false
var vertical_drag : bool = false

var target_point : Vector3 = Vector3.ZERO
var drag_starting_point : Vector3 = Vector3.ZERO
var dragging_x_limit : float = X_LIMIT

var playable_component : PlayableComponent :
	get() :
		if body == null : return
		return body.playable_component
var snappable_component : SnappableComponent :
	get() :
		if body == null : return
		return body.snappable_component

var body_position : Vector3 : 
	set(new_position): body.global_position = new_position
	get() : return body.global_position
var body_rotation : Vector3 :
	set(new_rotation_degrees): body.rotation_degrees = new_rotation_degrees
	get() : return body.rotation_degrees
var horizontal_direction : Vector2i :
	get() :
		var result : Vector2i = Vector2i.ZERO
		if body_position.x > target_point.x : result = Vector2i(1, 0) # LEFT
		else : if body_position.x < target_point.x : result = Vector2i(0, 1) # RIGHT
		return result
var vertical_direction : Vector2i :
	get() :
		var result : Vector2i = Vector2i.ZERO
		if body_position.y < target_point.y : result = Vector2i(1, 0) # UP
		else : if body_position.y > target_point.y : result = Vector2i(0, 1) # DOWN
		return result
var depth_direction : Vector2i :
	get() :
		var result : Vector2i = Vector2i.ZERO
		if body_position.z > target_point.z : result = Vector2i(1, 0) # FRONT
		else : if body_position.z < target_point.z : result = Vector2i(0, 1) # REAR
		return result

var dragging_left : bool :
	get() : return horizontal_direction.x
var dragging_right : bool :
	get() : return horizontal_direction.y
var dragging_up : bool :
	get() : return vertical_direction.x
var dragging_down : bool :
	get() : return vertical_direction.y
var dragging_front : bool :
	get() : return depth_direction.x
var dragging_rear : bool :
	get() : return depth_direction.y

func stop_dragging() :
	if body == null || !manipulable && being_manipulated : return
	horizontal_drag = false
	vertical_drag = false
	stopped_dragging.emit()
	
	target_point = Vector3.ZERO
	if _manipulator_list.has(current_manipulator): _manipulator_list.erase(current_manipulator)
	current_manipulator = null
	_freeze(false)

func dragged() -> bool : return horizontal_drag || vertical_drag # || (snappable_component && snappable_component.attacking_snap)

func double_dragged() -> bool : return horizontal_drag && vertical_drag 

func _freeze(freeze_value):
	if body == null: return
	if freeze && body.freezable_component:
		body.freezable_component.freeze.emit(freeze_value, current_manipulator)

func is_not_moving(digits : int = 2) -> bool :
	return global.round_to_decimal(_next_position, digits) == global.round_to_decimal(target_point, digits)

func _ready() -> void:
	if body == null : body = get_parent_node_3d()
	
	_stop_dragging_timer.one_shot = true
	_stop_dragging_timer.wait_time = NOT_DRAGGING_LIMIT
	_stop_dragging_timer.timeout.connect(func () :
		if is_not_moving() && dragged() : 
			print("Yup it bugged, stop it my child")
			stop_dragging())
	add_child(_stop_dragging_timer)
	
	started_dragging.connect(func() : drag_starting_point = body_position )
	
	stopped_dragging.connect(func (): 
		if !body || snappable_component == null : return
		snappable_component.grounded.emit() )
		
	drag.connect(func(horizontal : bool, vertical : bool, target : Vector3, strength : float, player_requested_to_drag : Manipulator):
		if !manipulable && player_requested_to_drag : return
		if !vertical_drag && !horizontal_drag && (vertical || horizontal) && ( snappable_component && !snappable_component.attacking_snap ): 
			started_dragging.emit()
		horizontal_drag = horizontal
		vertical_drag = vertical
		target_point = target
		current_manipulator = player_requested_to_drag
		if current_manipulator && !_manipulator_list.has(current_manipulator):
			_manipulator_list.append(current_manipulator)
		if override_drag_strength : _custom_dragging_strength = strength)

func _process(delta: float) -> void:
	if !active || body == null : return
	
	if !dragged() : return
	
	# Freeze in case intended
	_freeze(freeze)
	
	## DRAG CALCULATION ##
	
	var final_y_z : Vector2 = Vector2(target_point.y, target_point.z)
	
	# Check if the object is being dragged in both axes
	if !double_dragged():
		if vertical_drag : final_y_z.x = body_position.y
		if horizontal_drag : final_y_z.y = body_position.z
	
	# Check if the position is within the set threshold, if not, override it to stay within y limits
	if final_y_z.x < dragging_x_limit : final_y_z.x = dragging_x_limit
	
	# Set the final dragging point after calculations
	var final_drag_point : Vector3 = Vector3(target_point.x, final_y_z.x, final_y_z.y)
	
	# Verify final drag strength
	var final_strength : float = dragging_strength
	if override_drag_strength : final_strength = _custom_dragging_strength # Check if we respect own strength or accept outside manipulation strength 
	
	_next_position = lerp(body_position, final_drag_point, final_strength * delta) # change the body's position employing final calculations
	body_position = _next_position
	
	if body.rotatable_component != null && fix_rotation : body.rotatable_component.fix_rotation()
	
	if is_not_moving() : _stop_dragging_timer.start() ; return
	if !drag_animation || snappable_component && ( snappable_component.is_handled || ( snappable_component.keyboard_recovery && is_not_moving(1) )) : return 
	
	var final_rotation := Vector3(body.rotation_degrees.x, body.rotation_degrees.y, body.rotation_degrees.z)
	
	var is_keyboard : bool = false
	if snappable_component : is_keyboard = snappable_component.keyboard_recovery
	if !is_keyboard :
		# POINTER DRAGGING ANIMATION
		if dragging_left : final_rotation.z -= drag_animation_rotation_distance
		else : if dragging_right : final_rotation.z += drag_animation_rotation_distance
	
		if dragging_front : final_rotation.x += drag_animation_rotation_distance
		else : if dragging_rear : final_rotation.x -= drag_animation_rotation_distance
		
	else : if playable_component != null :
		# KEYBOARD DRAGGING ANIMATION
		match playable_component.last_movement_id :
			1 : final_rotation.z -= drag_animation_rotation_distance # LEFT
			2 : final_rotation.z += drag_animation_rotation_distance # RIGHT
			3 : final_rotation.x += drag_animation_rotation_distance # FRONT
			4 : final_rotation.x -= drag_animation_rotation_distance # REAR
			5 : final_rotation.x += drag_animation_rotation_distance ; final_rotation.z -= drag_animation_rotation_distance # FRONT LEFT
			6 : final_rotation.x += drag_animation_rotation_distance ; final_rotation.z += drag_animation_rotation_distance # FRONT RIGHT
			7 : final_rotation.x -= drag_animation_rotation_distance ; final_rotation.z -= drag_animation_rotation_distance # REAR LEFT
			8 : final_rotation.x -= drag_animation_rotation_distance ; final_rotation.z += drag_animation_rotation_distance # REAR RIGHT
	
	body.rotation_degrees = lerp(body.rotation_degrees, final_rotation, drag_animation_force * delta)
