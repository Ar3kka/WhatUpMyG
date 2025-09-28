class_name RotatableComponent extends Node3D

signal rotate(new_rotation_vector : Vector3, is_player_rotating : Manipulator)

## RECOMMENDED SETTINGS
const FIXATED_AXIS : Vector3 = Vector3(0, 1, 0)
const STANDARD_STRENGTH : float = 5.0
const STANDARD_FIXATION_STRENGTH : float = 0.05

var current_manipulator : Manipulator
var _manipulator_list : Array[Manipulator] = []

## The affected 3d rigidbody piece.
@export var body : Piece
@export var active : bool = true
## Freeze 3d node body when rotating
@export var freeze : bool = true
## Fixate the altered axis in the vector with the body's 3d node rotation degrees, any alterations to the fixated rotation axis will be restored
@export var fixed_axis_vector : Vector3 = FIXATED_AXIS
## Set the custom strength for fixing the rotation towards the set standard rotation in the fixed axis vector.
@export var fix_rotation_strength : float = STANDARD_FIXATION_STRENGTH 
## Select in which direction the set 3d node body has to rotate to. Positive = one side. Negative = opposite side. Zero = no rotation in corresponding axis.
@export var rotation_vector : Vector3 = Vector3.ZERO
## Set the general strength applying it to the complete strength vector.
@export var general_strength : float = STANDARD_STRENGTH :
	set(new_general_strength): rotation_strength_vector = Vector3(general_strength, general_strength, general_strength)
## Set custom strength ignoring the general strength, in case of custom axis strength is intended
@export var rotation_strength_vector : Vector3 = Vector3(STANDARD_STRENGTH, STANDARD_STRENGTH, STANDARD_STRENGTH)


func is_rotating() -> bool : return rotation_vector != Vector3.ZERO

func is_fixated() -> bool: return fixed_axis_vector != Vector3.ZERO

func _ready():
	if body == null : body = get_parent_node_3d()
	rotate.connect(func(new_rotation_vector : Vector3, is_player_rotating : Manipulator):
		rotation_vector = new_rotation_vector
		current_manipulator = is_player_rotating
		if current_manipulator && !_manipulator_list.has(current_manipulator):
			_manipulator_list.append(current_manipulator))

func _freeze(freeze_value):
	if body == null : return
	if freeze && body.freezable_component:
		body.freezable_component.freeze.emit(freeze_value, current_manipulator)

func get_standard_rotation() -> Vector3:
	if body == null || fixed_axis_vector == Vector3.ZERO: return Vector3.ZERO
	
	var final_standard_rotation : Vector3 = Vector3.ZERO
	
	if fixed_axis_vector.x != 0: final_standard_rotation.x = body.rotation_degrees.x
	if fixed_axis_vector.y != 0: final_standard_rotation.y = body.rotation_degrees.y
	if fixed_axis_vector.z != 0: final_standard_rotation.z = body.rotation_degrees.z
	
	return Vector3(final_standard_rotation.x, final_standard_rotation.y, final_standard_rotation.z) 

func stop_rotating():
	if !is_rotating(): return
	rotation_vector = Vector3.ZERO
	if _manipulator_list.has(current_manipulator): _manipulator_list.erase(current_manipulator)
	current_manipulator = null
	_freeze(false)

func fix_rotation():
	if body == null || !is_fixated(): return
	var standard_rotation = get_standard_rotation()
	if body.rotation_degrees == standard_rotation : return
	body.rotation_degrees = lerp(body.rotation_degrees, standard_rotation, STANDARD_FIXATION_STRENGTH)

func _process(delta: float):
	if !active || body == null || !is_rotating() : return
	
	_freeze(true)
	
	fix_rotation()
	
	var final_rotation : Vector3 = Vector3.ZERO
	
	if rotation_vector.x != 0:
		final_rotation.x = -1
		if rotation_vector.x > 0: final_rotation.x = 1
	if rotation_vector.y != 0:
		final_rotation.y = -1
		if rotation_vector.y > 0: final_rotation.y = 1
	if rotation_vector.z != 0:
		final_rotation.z = -1
		if rotation_vector.z > 0: final_rotation.z = 1
		
	body.rotate_x(final_rotation.x * rotation_strength_vector.x * delta)
	body.rotate_y(final_rotation.y * rotation_strength_vector.y * delta)
	body.rotate_z(final_rotation.z * rotation_strength_vector.z * delta)
