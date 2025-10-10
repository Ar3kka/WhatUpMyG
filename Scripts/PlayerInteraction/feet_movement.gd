class_name Feet extends Node3D

const STANDARD_SPEED : float = 7.5
const STANDARD_SMOOTHNESS : float = 0.03

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
var nervous_signals : MovableComponent

func _ready() -> void:
	if !body : body = get_parent_node_3d()
	body.found_eyes.connect(_add_nervous_signals)

func _add_nervous_signals():
	if body == null || body.eyes == null : return
	nervous_signals = MovableComponent.new().instantiate(body.eyes)
	nervous_signals.weight = smoothness
	body.add_child(nervous_signals)

func _process(delta):
	if !active : return
	var input_dir := Input.get_vector("Stride Left", "Stride Right", "Forward", "Back")
	if !input_dir: return
	if input_dir == Vector2.UP || Vector2.DOWN:
		var final_z : float = input_dir.y * speed * delta
		global_position.z += final_z
	if input_dir == Vector2.RIGHT || Vector2.LEFT:
		var final_x : float = input_dir.x * speed * delta
		global_position.x += final_x
	if nervous_signals: nervous_signals.translate.emit(global_position)
