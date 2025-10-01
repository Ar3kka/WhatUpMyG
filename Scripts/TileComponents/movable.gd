class_name MovableComponent extends Node3D

signal translate(translation_vector : Vector3)
signal finished_translation()

const STANDARD_UP_DOWN_DISTANCE : float = 0.250
const STANDARD_LEFT_RIGHT_DISTANCE : float = 1.0
const STANDARD_TRANSLATION_STRENGTH : float = 0.05

@export var active : bool = true
@export var node : Node3D
var _global_position : Vector3 = Vector3.ZERO :
	set(new_position):
		if node == null : return
		node.global_position = new_position
	get():
		if node == null : return Vector3.ZERO
		return node.global_position
var _translation_vector : Vector3 = Vector3.ZERO :
	set(new_vector) :
		if new_vector == Vector3.ZERO :
			_translation_vector = new_vector
			return
		new_vector.x += global_position.x
		new_vector.y += global_position.y
		new_vector.z += global_position.z
		_translation_vector = new_vector

func _ready() -> void:
	if node == null: node = get_parent_node_3d()
	translate.connect(translation)

func translation(translation_direction : Vector3 = Vector3.ZERO):
	_translation_vector = translation_direction
	
func move_up(times : float = 1.0): _translation_vector = Vector3(0, STANDARD_UP_DOWN_DISTANCE * times, 0)

func move_down(times : float = 1.0): _translation_vector = Vector3(0, -STANDARD_UP_DOWN_DISTANCE * times, 0)

func move_left(times : float = 1.0): _translation_vector = Vector3(-STANDARD_LEFT_RIGHT_DISTANCE * times, 0, 0)

func move_right(times : float = 1.0): _translation_vector = Vector3(STANDARD_LEFT_RIGHT_DISTANCE * times, 0, 0)

func move_forth(times : float = 1.0): _translation_vector = Vector3(0, 0, STANDARD_LEFT_RIGHT_DISTANCE * times)

func move_back(times : float = 1.0): _translation_vector = Vector3(0, 0, -STANDARD_LEFT_RIGHT_DISTANCE * times)

func stop_translation():
	_translation_vector = Vector3.ZERO
	finished_translation.emit()

func is_translating() -> bool : return _translation_vector != Vector3.ZERO

func _has_translation_reached_goal() -> bool :
	return _round_to_decimal(_global_position) == _round_to_decimal(_translation_vector)

func _round_to_decimal(num, digit : int = 2):
	return round(num * pow(10.0, digit)) / pow(10.0, digit)
	
func _process(delta: float) -> void:
	if !active || node == null : return
	
	if _has_translation_reached_goal() : stop_translation()
	
	if !is_translating() : return
	
	_global_position = lerp(_global_position, _translation_vector, STANDARD_TRANSLATION_STRENGTH)
