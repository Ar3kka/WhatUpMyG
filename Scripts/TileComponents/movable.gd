class_name MovableComponent extends Node3D

signal translate(translation_vector : Vector3)
signal finished_translation()
signal reset()

const SCENE : PackedScene = preload("res://Scenes/Components/movable.tscn")
const STANDARD_UP_DOWN_DISTANCE : float = 0.250
const STANDARD_LEFT_RIGHT_DISTANCE : float = 1.0
const STANDARD_TRANSLATION_STRENGTH : float = 0.05
const STANDARD_MULTIPLIER : float = 1.0
const STANDARD_GLOBAL_POSITION : Vector3 = Vector3.ZERO

@export var active : bool = true
@export var node : Node3D :
	set(new_node):
		node = new_node
		if node == null : 
			standard_position = STANDARD_GLOBAL_POSITION
			return
		standard_position = node.global_position
@export var standard_position : Vector3 :
	get():
		if standard_position == null : return Vector3.ZERO
		return standard_position

var _global_position : Vector3 :
	set(new_position):
		if node == null : return
		node.global_position = new_position
	get():
		if node == null : return standard_position
		return node.global_position
var _reset : bool = false :
	set(new_reset) : 
		_reset = new_reset
		if _reset : _translation_vector = standard_position
var _translation_vector : Vector3 :
	set(new_vector) :
		if new_vector == standard_position :
			_translation_vector = new_vector
			return
		new_vector.x += global_position.x
		new_vector.y += global_position.y
		new_vector.z += global_position.z
		_translation_vector = new_vector
	get():
		if _translation_vector == null : return standard_position
		return _translation_vector
var vector_states : Array[Vector3] = [] :
	get():
		if vector_states.size() < 1 || vector_states == null : return [standard_position]
		return vector_states

func set_standard(add_to_states : bool = false): 
	standard_position = _global_position
	if add_to_states : vector_states.append(standard_position)

func change_standard_to_state(state_number : int):
	standard_position = vector_states[state_number]

func change_to_state(state_number : int):
	_translation_vector = vector_states[state_number]

func remove_state(state : Vector3) -> bool :
	for index in range(vector_states.size()):
		index -= 1
		if vector_states[index] == state : 
			vector_states.remove_at(index)
			return true
	return false

func add_state(new_state : Vector3, clear : bool = false): 
	if clear : clear()
	vector_states.append(new_state)

func clear(): vector_states = []

func _ready() -> void:
	if node == null: node = get_parent_node_3d()
	standard_position = _global_position
	_translation_vector = standard_position
	translate.connect(translation)
	finished_translation.connect(stop_translation)
	reset.connect(func (new_reset_value : bool = true) :
		_reset = new_reset_value )

func translation(translation_direction : Vector3 = standard_position):
	_translation_vector = translation_direction
	
func move_up(times : float = STANDARD_MULTIPLIER): _translation_vector = Vector3(0, STANDARD_UP_DOWN_DISTANCE * times, 0)

func move_down(times : float = STANDARD_MULTIPLIER): _translation_vector = Vector3(0, -STANDARD_UP_DOWN_DISTANCE * times, 0)

func move_left(times : float = STANDARD_MULTIPLIER): _translation_vector = Vector3(-STANDARD_LEFT_RIGHT_DISTANCE * times, 0, 0)

func move_right(times : float = STANDARD_MULTIPLIER): _translation_vector = Vector3(STANDARD_LEFT_RIGHT_DISTANCE * times, 0, 0)

func move_forth(times : float = STANDARD_MULTIPLIER): _translation_vector = Vector3(0, 0, STANDARD_LEFT_RIGHT_DISTANCE * times)

func move_back(times : float = STANDARD_MULTIPLIER): _translation_vector = Vector3(0, 0, -STANDARD_LEFT_RIGHT_DISTANCE * times)

func stop_translation():
	_translation_vector = standard_position
	_reset = false

func is_translating() -> bool : 
	return _round_to_decimal(_translation_vector) != _round_to_decimal(standard_position) || _reset

func _has_translation_reached_goal() -> bool :
	return _round_to_decimal(_global_position) == _round_to_decimal(_translation_vector)

func _round_to_decimal(num, digit : int = 2):
	return round(num * pow(10.0, digit)) / pow(10.0, digit)

func instantiate(initial_node_to_move : Node3D, new_active_state : bool = true) -> MovableComponent:
	var new_movable : MovableComponent = SCENE.instantiate()
	new_movable.active = new_active_state
	new_movable.node = initial_node_to_move
	new_movable.global_position = new_movable.node.global_position
	new_movable.position = new_movable.node.position
	return new_movable

func _process(delta: float) -> void:
	if !active || node == null : return
	
	if _has_translation_reached_goal() && is_translating() : finished_translation.emit()
	
	if !is_translating() : return
	
	_global_position = lerp(_global_position, _translation_vector, STANDARD_TRANSLATION_STRENGTH)
