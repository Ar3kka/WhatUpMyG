class_name DraggableComponent extends Node3D

signal drag(horizontal : bool, vertical : bool, target : Vector3, strength : float, player_requested_to_drag : bool)

## RECOMMENDED SETTINGS
const ROTATION_STRENGTH : float = 0.05
const DRAGGING_STRENGTH : float = 0.1
const X_LIMIT : float = 0.0
const FREEZABLE_NODE = "Freezable"

var player_manipulation : bool = true

@export var body : RigidBody3D
@export var dragging_strength : float = DRAGGING_STRENGTH
@export var active : bool = true
@export var freeze : bool = true
@export var rotate : bool = true
@export var rotation_strength : float = ROTATION_STRENGTH

@export var override_drag_strength : bool = true
var _custom_dragging_strength : float

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
	if body == null : return
	horizontal_drag = false
	vertical_drag = false
	target_point = Vector3.ZERO
	_freeze(false)

func dragged() -> bool : return horizontal_drag || vertical_drag

func double_dragged() -> bool : return horizontal_drag && vertical_drag 

func _freeze(freeze_value : bool):
	if body == null : return
	var freezable_component : FreezableComponent = body.get_node(FREEZABLE_NODE)
	if freezable_component != null: freezable_component.freeze.emit(freeze_value, player_manipulation)

func _ready() -> void:
	if body == null : body = get_parent_node_3d()
	drag.connect(func(horizontal : bool, vertical : bool, target : Vector3, strength : float, player_requested_to_drag : bool):
		horizontal_drag = horizontal
		vertical_drag = vertical
		target_point = target
		player_manipulation = player_requested_to_drag
		if override_drag_strength : _custom_dragging_strength = strength)

func _process(_delta: float) -> void:
	if !active: return
	
	if body == null:
		print("I have no body bro, I'm all alone with my thoughts")
		return
	
	if !dragged() : return
	
	#print("I'm being dragged, please god, help")
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
	
	if !rotate : return
	
	var standard_rotation : Vector3 = Vector3(0, body_rotation.y, 0)
	if body_rotation != standard_rotation : 
		body_rotation = lerp(body_rotation, standard_rotation, rotation_strength)
