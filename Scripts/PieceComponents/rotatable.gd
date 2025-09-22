class_name RotatableComponent extends Node3D

signal rotate(new_rotation_degrees : Vector3, is_player_rotating : bool)

var player_manipulation : bool = true
@export var body : RigidBody3D
@export var active : bool = true
@export var rotation_strength : float = 10.0
@export var rotation_vector : Vector3 :
	set(new_rotation_degrees):
		if body == null || !active: return
		body.rotation_degrees = new_rotation_degrees
	get():
		if body == null || !active: return Vector3.ZERO
		return body.rotation_degrees
		
func _ready():
	if body == null : body = get_parent_node_3d()
	rotate.connect(func(new_rotation_degrees : Vector3, is_player_rotating : bool):
		rotation_vector = new_rotation_degrees
		player_manipulation = is_player_rotating)
