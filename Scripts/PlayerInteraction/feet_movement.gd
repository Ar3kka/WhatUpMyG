class_name Feet extends Node3D

const STANDARD_SPEED : float = 7.5

@export var active : bool = true :
	get(): 
		if !body : return false
		return active
@export var body : Manipulator
@export var speed : float = STANDARD_SPEED
@export var smooth : bool = true
var walking : bool = false
var nervous_signals : MovableComponent :
	get():
		if !nervous_signals : _add_nervous_signals()
		return nervous_signals

func _ready() -> void:
	if !body : body = get_parent_node_3d()

func _add_nervous_signals():
	if !body || !body.eyes : return
	nervous_signals = MovableComponent.new().instantiate(body.eyes)
	add_child(nervous_signals)

func _process(delta):
	var input_dir := Input.get_vector("Stride Left", "Stride Right", "Forward", "Back")
	if !input_dir: return
	walking = false
	if input_dir == Vector2.UP || Vector2.DOWN:
		var final_z : float = input_dir.y * speed * delta
		if smooth : global_position.z += final_z
		else : body.global_position.z += final_z
		walking = true
	if input_dir == Vector2.RIGHT || Vector2.LEFT:
		var final_x : float = input_dir.x * speed * delta
		if smooth : global_position.x += final_x
		else : body.global_position.x += final_x
		walking = true
	if walking && body && nervous_signals && smooth: 
		nervous_signals.translate.emit(global_position)
