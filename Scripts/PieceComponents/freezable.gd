class_name FreezableComponent extends Node3D

signal freeze(freezing : bool, player_manipulation : bool)

## RECOMMENDED MODE
const FREEZE_MODE = RigidBody3D.FREEZE_MODE_KINEMATIC
const COMPONENT_READER = "PieceReader"
@export var component_reader : PieceReader

@export var body : RigidBody3D
@export var active : bool = true
var freeze_by_player_manipulation : bool = false

@export var frozen : bool :
	set(freezing_value): 
		if !active || body == null || freezing_value == body.freeze: return
		if freeze_by_player_manipulation:
			if component_reader && component_reader.team_component && !component_reader.team_component.is_observed_by_same_team() : return
		#if freezing_value: print("I'M FROZEN")
		#else: print("I'M HOT")
		body.freeze = freezing_value
	get(): return body.freeze
@export var freeze_mode : RigidBody3D.FreezeMode :
	set(new_value): 
		if body == null: return
		body.freeze_mode = new_value
	get(): return body.freeze_mode

func _ready() -> void:
	if !body: body = get_parent_node_3d()
	if body && component_reader == null : component_reader = body.get_node(COMPONENT_READER)
	freeze_mode = FREEZE_MODE
	freeze.connect(func(freezing : bool, player_manipulation : bool): 
		frozen = freezing
		freeze_by_player_manipulation = player_manipulation)
