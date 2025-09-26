class_name Feet extends Node3D

const STANDARD_SPEED : float = 7.5

@export var body : Manipulator
@export var speed : float = STANDARD_SPEED

func _ready() -> void:
	if !body : body = get_parent_node_3d()

func _process(delta):
	var input_dir := Input.get_vector("Stride Left", "Stride Right", "Forward", "Back")
	if !input_dir: return
	if input_dir == Vector2.UP || Vector2.DOWN:
		body.global_position.z += input_dir.y * speed * delta
	if input_dir == Vector2.RIGHT || Vector2.LEFT:
		body.global_position.x += input_dir.x * speed * delta
