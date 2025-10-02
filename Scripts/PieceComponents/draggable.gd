class_name DraggableComponent extends Node3D

signal drag(horizontal : bool, vertical : bool, target : Vector3, strength : float, player_requested_to_drag : Manipulator)
signal stopped_dragging()

## RECOMMENDED SETTINGS
const ROTATION_STRENGTH : float = 0.05
const DRAGGING_STRENGTH : float = 0.1
const X_LIMIT : float = 0.0

@export var body : Piece
@export var active : bool = true
## The dragging strength for when this piece is being dragged
@export var dragging_strength : float = DRAGGING_STRENGTH
## Whether or not the individual drag strength set for each piece should be overwritten by the dragging
## strength of the manipulator
@export var override_drag_strength : bool = true
var _custom_dragging_strength : float
## Whether or not this tile is draggable by the means of manipulation (by a player with the mouse)
@export var manipulable : bool = true
var current_manipulator : Manipulator
var _manipulator_list : Array[Manipulator] = []
var being_manipulated : bool :
	set(new_value) : return
	get(): return _manipulator_list.size() > 0 || current_manipulator
## Freeze all physics interaction to kinematic when the piece is being dragged
@export var freeze : bool = true
## Fix the rotation by the standard rotation set in the rotatable component (only works if piece is rotatable)
@export var fix_rotation : bool = true

var horizontal_drag : bool = false
var vertical_drag : bool = false

var target_point : Vector3 = Vector3.ZERO
var dragging_x_limit : float = X_LIMIT

var body_position : Vector3 : 
	set(new_position): body.global_position = new_position
	get(): return body.global_position
var body_rotation : Vector3 :
	set(new_rotation_degrees): body.rotation_degrees = new_rotation_degrees
	get(): return body.rotation_degrees

func stop_dragging() :
	if body == null || !manipulable && being_manipulated : return
	horizontal_drag = false
	vertical_drag = false
	stopped_dragging.emit()
	target_point = Vector3.ZERO
	if _manipulator_list.has(current_manipulator): _manipulator_list.erase(current_manipulator)
	current_manipulator = null
	_freeze(false)

func dragged() -> bool : return horizontal_drag || vertical_drag

func double_dragged() -> bool : return horizontal_drag && vertical_drag 

func _freeze(freeze_value):
	if body == null: return
	if freeze && body.freezable_component:
		body.freezable_component.freeze.emit(freeze_value, current_manipulator)

func _ready() -> void:
	if body == null : body = get_parent_node_3d()
	
	stopped_dragging.connect(func (): 
		if !body : return
		var snappable_component : SnappableComponent = body.snappable_component
		if snappable_component : snappable_component.grounded.emit()
		if snappable_component._playable && snappable_component.snapped_to : snappable_component.snap.emit())
		
	drag.connect(func(horizontal : bool, vertical : bool, target : Vector3, strength : float, player_requested_to_drag : Manipulator):
		if !manipulable && player_requested_to_drag : return
		horizontal_drag = horizontal
		vertical_drag = vertical
		target_point = target
		current_manipulator = player_requested_to_drag
		if current_manipulator && !_manipulator_list.has(current_manipulator):
			_manipulator_list.append(current_manipulator)
		if override_drag_strength : _custom_dragging_strength = strength)

func _process(_delta: float) -> void:
	if !active: return
	
	if body == null: return
	
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
	
	body_position = lerp(body_position, final_drag_point, final_strength) # change the body's position employing final calculations
	
	if body.rotatable_component == null || !fix_rotation : return
	body.rotatable_component.fix_rotation()
