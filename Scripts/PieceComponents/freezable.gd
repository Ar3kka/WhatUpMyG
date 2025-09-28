class_name FreezableComponent extends Node3D

signal freeze(freezing : bool, player_manipulation : Manipulator)

## RECOMMENDED MODE
const FREEZE_MODE = RigidBody3D.FREEZE_MODE_KINEMATIC

@export var body : Piece
@export var active : bool = true
var debug : bool = false

var current_manipulator : Manipulator
var _manipulator_list : Array[Manipulator] = []

@export var frozen : bool :
	set(freezing_value): 
		if !active || body == null || freezing_value == body.freeze: return
		if current_manipulator && body.team_component && !body.team_component.is_observed_by_same_team() : return
		if freezing_value: 
			if current_manipulator && !_manipulator_list.has(current_manipulator):
				_manipulator_list.append(current_manipulator)
			if debug: print("I'M FROZEN")
		else:
			if _manipulator_list.has(current_manipulator):
				print(current_manipulator)
				_manipulator_list.erase(current_manipulator)
				current_manipulator = null
			if debug: print("I'M HOT")
		body.freeze = freezing_value
	get(): return body.freeze
@export var freeze_mode : RigidBody3D.FreezeMode :
	set(new_value): 
		if body == null: return
		body.freeze_mode = new_value
	get(): return body.freeze_mode

func _ready() -> void:
	if !body: body = get_parent_node_3d()
	freeze_mode = FREEZE_MODE
	freeze.connect(func(freezing : bool, player_manipulation : Manipulator): 
		current_manipulator = player_manipulation
		frozen = freezing)
