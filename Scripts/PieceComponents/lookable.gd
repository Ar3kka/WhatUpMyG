class_name LookableComponent extends Node3D

signal look(value : bool)

@export var body : RigidBody3D
@export var active : bool = true
var looked_at : bool = false

func _ready() -> void:
	look.connect(func(value : bool): looked_at = value)
