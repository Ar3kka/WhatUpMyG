class_name Feet extends Node3D

signal nerve_spine() 

const STANDARD_FOCUS_FORCE : float = 35.0
const STANDARD_SPEED : float = 7.5
const STANDARD_SMOOTHNESS : float = 0.03
const STANDARD_PROXIMITY : float = 1.75
const STANDARD_REMOTENESS : float = 6.0
const STANDARD_VERTICAL_LIMIT : Vector2 = Vector2(7.0, -20.0)
const STANDARD_HORIZONTAL_LIMIT : Vector2 = Vector2(-8.50, 1.75)

@export var active : bool = true :
	get(): 
		if !body : return false
		return active
@export var body : Manipulator
## The overall speed of movement and translation.
@export var speed : float = STANDARD_SPEED
## The weight on which the movement will be carried, from 0.0 to 1.0.
@export var smoothness : float = STANDARD_SMOOTHNESS :
	set(new_value) :
		if new_value > 1.0 : new_value = 1.0
		else : if new_value < 0.0 : new_value = 0.0
		smoothness = new_value
		if nervous_signals : nervous_signals.weight = smoothness
@export_group("Delimitations")
@export var lock_left : bool = true
@export var lock_right : bool = true
@export var vertical_limit : Vector2 = STANDARD_VERTICAL_LIMIT
@export var lock_back : bool = true
@export var lock_forth : bool = true
@export var horizontal_limit : Vector2 = STANDARD_HORIZONTAL_LIMIT
@export_group("Focus")
## The overall speed of focus.
@export var focus_force : float = STANDARD_FOCUS_FORCE
## 
@export var close_focus : bool = true
@export var proximity_limit : float = STANDARD_PROXIMITY
var at_proximity_limit : bool = false
@export var far_focus : bool = true
@export var remoteness_limit : float = STANDARD_REMOTENESS
var at_remoteness_limit : bool = false
var nervous_signals : MovableComponent

func _ready() -> void:
	if !body : body = get_parent_node_3d()
	body.found_eyes.connect(_add_nervous_signals)

func _add_nervous_signals():
	if body == null || body.eyes == null : return
	nervous_signals = MovableComponent.new().instantiate(body.eyes)
	nervous_signals.weight = smoothness
	body.add_child(nervous_signals)
	nerve_spine.emit()

func _process(delta):
	if !active : return
	
	var scroll : bool = false
	var final_y : float = 0
	
	if Input.is_action_just_pressed("Scroll Back") && far_focus:
		final_y = 1 * focus_force * delta ; scroll = true
		at_proximity_limit = false
		if final_y + global_position.y > remoteness_limit : 
			at_remoteness_limit = true
			final_y = 0
		else: at_remoteness_limit = false
			
	else : if Input.is_action_just_pressed("Scroll In") && close_focus:
		final_y = -1 * focus_force * delta ; scroll = true
		at_remoteness_limit = false
		if final_y + global_position.y < proximity_limit :
			at_proximity_limit = true
			final_y = 0
		else : at_proximity_limit = false
	
	global_position.y += final_y
	
	var input_dir := Input.get_vector("Stride Left", "Stride Right", "Forward", "Back")
	
	if !input_dir && !scroll: return
	
	if input_dir == Vector2.UP || Vector2.DOWN:
		var final_z : float = input_dir.y * speed * delta
		if (((lock_back && global_position.z + final_z < vertical_limit.x) || (!lock_back)) &&
			((lock_forth && global_position.z + final_z > vertical_limit.y) || (!lock_forth))) : 
				global_position.z += final_z
	if input_dir == Vector2.RIGHT || Vector2.LEFT:
		var final_x : float = input_dir.x * speed * delta
		if (((lock_left && global_position.x + final_x > horizontal_limit.x) || (!lock_left)) &&
			((lock_right && global_position.x + final_x < horizontal_limit.y) || (!lock_right))) : 
				global_position.x += final_x
	
	if nervous_signals: nervous_signals.translate.emit(global_position)
