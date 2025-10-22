class_name MovableComponent extends Node3D

signal translate(translation_vector : Vector3)
signal finished_translation()
signal reset(new_reset_value : bool, reset_vector_states : bool)

const SCENE : PackedScene = preload("res://Scenes/Components/movable.tscn")
const STANDARD_UP_DOWN_DISTANCE : float = 0.250
const STANDARD_LEFT_RIGHT_DISTANCE : float = 1.0
const STANDARD_TRANSLATION_STRENGTH : float = 0.05
const STANDARD_MULTIPLIER : float = 1.0
const STANDARD_GLOBAL_POSITION : Vector3 = Vector3.ZERO
const STANDARD_MULTIPLIER_VECTOR : Vector2 = Vector2(STANDARD_MULTIPLIER, STANDARD_MULTIPLIER)

@export var active : bool = true
@export var node : Node3D :
	set(new_node):
		node = new_node
		if node == null : 
			standard_position = STANDARD_GLOBAL_POSITION
			return
		standard_position = node.global_position
## The general translation strength, ranging from 0 to 1.
@export var weight : float = STANDARD_TRANSLATION_STRENGTH
## The position translation strength, ranging from 0 to 1.
@export var standard_position : Vector3 :
	get():
		if standard_position == null : return Vector3.ZERO
		return standard_position
@export_group("Translation Distance Settings")
@export var add_vertical_states : bool = false
@export var vertical_multiplier : Vector2 = STANDARD_MULTIPLIER_VECTOR
@export var vertical_distance : Vector2 = Vector2(STANDARD_UP_DOWN_DISTANCE, -STANDARD_UP_DOWN_DISTANCE) :
	get () : return vertical_distance * vertical_multiplier
@export var add_horizontal_states : bool = false
@export var horizontal_multiplier : Vector2 = STANDARD_MULTIPLIER_VECTOR
@export var horizontal_distance : Vector2 = Vector2(-STANDARD_LEFT_RIGHT_DISTANCE, STANDARD_LEFT_RIGHT_DISTANCE) :
	get () : return vertical_distance * horizontal_multiplier
@export var add_depth_states : bool = false
@export var depth_multiplier : Vector2 = STANDARD_MULTIPLIER_VECTOR
@export var depth_distance : Vector2 = Vector2(STANDARD_LEFT_RIGHT_DISTANCE, -STANDARD_LEFT_RIGHT_DISTANCE) :
	get () : return depth_distance * depth_multiplier

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
var _reset_translation_vector : bool = false
var _translation_vector : Vector3 :
	set(new_vector) :
		if _reset_translation_vector :
			_translation_vector = new_vector
			return
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
var vector_states : Array[Vector3] = []

func is_current_state(state : int = 0) :
	return get_current_state() == state

func get_current_state() -> int :
	for index in (vector_states.size()) :
		if vector_states[index - 1] == _translation_vector : return index  
	return -1

func set_standard(add_to_states : bool = false): 
	standard_position = _global_position
	if add_to_states : vector_states.append(standard_position)

func change_standard_to_state(state_number : int, reset_after : bool = false):
	standard_position = vector_states[state_number]
	if reset_after : reset.emit()

func change_to_state(state_number : int, reset : bool = true ):
	_reset_translation_vector = reset
	_translation_vector = vector_states[state_number]
	_reset_translation_vector = false

func remove_state(state : Vector3) -> bool :
	for index in range(vector_states.size()):
		if vector_states[index - 1] == state : 
			vector_states.remove_at(index - 1)
			return true
	return false 

func add_state(new_state : Vector3, clear : bool = false): 
	if clear : clear()
	vector_states.append(new_state)

func clear(add_standard : bool = true): 
	vector_states = []
	if !add_standard : return
	vector_states.append(standard_position)

func reset_vector_states():
	clear(false)
	set_standard(true) # state 0 : STANDARD
	change_to_state(0)
	
	if add_vertical_states :
		add_state(Vector3(standard_position.x, vertical_distance.x, standard_position.z)) # state 1 : UP
		add_state(Vector3(standard_position.x, vertical_distance.y, standard_position.z)) # state 2 : DOWN
	if add_horizontal_states :
		add_state(Vector3(horizontal_distance.x, standard_position.y, standard_position.z)) # state 3 : LEFT
		add_state(Vector3(horizontal_distance.y, standard_position.y, standard_position.z)) # state 4 : RIGHT
	if add_depth_states :
		add_state(Vector3(standard_position.x, standard_position.y, depth_distance.x)) # state 5 : FRONT
		add_state(Vector3(standard_position.x, standard_position.y, depth_distance.y)) # state 6 : REAR

func _ready() -> void:
	if node == null: node = get_parent_node_3d()
	set_standard(true) # state 0 : STANDARD
	change_to_state(0)
	#reset_vector_states()
	
	translate.connect(translation)
	finished_translation.connect(stop_translation)
	reset.connect(func (new_reset_value : bool = true, reset_vector_states : bool = false) :
		_reset = new_reset_value )

func translation(translation_direction : Vector3 = standard_position):
	_translation_vector = translation_direction
	
func move_up(): _translation_vector = Vector3(0, vertical_distance.x, 0)

func move_down(): _translation_vector = Vector3(0, vertical_distance.y, 0)

func move_left(): _translation_vector = Vector3(horizontal_distance.x, 0, 0)

func move_right(): _translation_vector = Vector3(horizontal_distance.y, 0, 0)

func move_forth(): _translation_vector = Vector3(0, 0, depth_distance.x)

func move_back(): _translation_vector = Vector3(0, 0, depth_distance.y)

func stop_translation():
	_global_position = _translation_vector
	_translation_vector = standard_position
	_reset = false

func is_translating() -> bool : 
	return _round_to_decimal(_translation_vector) != _round_to_decimal(standard_position) || _reset

func _has_translation_reached_goal() -> bool :
	return _round_to_decimal(_global_position) == _round_to_decimal(_translation_vector)

func _round_to_decimal(num, digit : int = 2):
	return round( num * pow( 10.0, digit ) ) / pow( 10.0, digit )

func instantiate(initial_node_to_move : Node3D) -> MovableComponent:
	var new_movable : MovableComponent = SCENE.instantiate()
	new_movable.node = initial_node_to_move
	return new_movable

func _process(delta: float) -> void:
	if !active || node == null : return
	
	if _has_translation_reached_goal() && is_translating() : finished_translation.emit()
	
	if !is_translating() : return
	
	_global_position = lerp(_global_position, _translation_vector, weight)
