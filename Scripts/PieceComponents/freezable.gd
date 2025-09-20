class_name FreezableComponent extends Node3D

signal freeze(freezing : bool, mode : RigidBody3D.FreezeMode)

@export var body : RigidBody3D
@export var active : bool = true 

func is_frozen() -> bool: return body.freeze

func frozen_mode() -> RigidBody3D.FreezeMode: return body.freeze_mode

func _ready() -> void:
	if !body: body = get_parent_node_3d()
	freeze.connect(func(freezing : bool, mode : RigidBody3D.FreezeMode): 
			body.freeze = freezing
			body.freeze_mode = mode)
