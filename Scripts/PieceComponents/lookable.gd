class_name LookableComponent extends Node3D

const COMPONENT_READER = "PieceReader"
@export var component_reader : PieceReader

signal look(value : bool)

@export var body : RigidBody3D
@export var active : bool = true
@export var freeze_on_look : bool = false
@export var freeze_if_selectable : bool = true
@export var freeze_if_draggable : bool = false

var looked_at : bool = false :
	set(new_value):
		if !active || body == null || looked_at == new_value : return
		looked_at = new_value
		
		if (component_reader == null 
		|| component_reader.freezable_component == null 
		|| _get_freeze_type() == 0): return
		
		var freeze_result : bool = false
		
		if ((freeze_on_look) || # freeze when object is set to freeze on look
		(freeze_if_selectable # freeze when object being looked is selectable
		&& component_reader.selectable_component
		&& component_reader.selectable_component.active) ||
		(freeze_if_draggable # freeze when object being looked is draggable
		&& component_reader.draggable_component
		&& component_reader.draggable_component.active)): 
			freeze_result = true
		
		if !looked_at: 
			freeze_result = false 
		
		component_reader.freezable_component.freeze.emit(freeze_result, true)

func _get_freeze_type() -> int:
	if freeze_on_look: return 1
	if freeze_if_selectable: return 2
	if freeze_if_draggable: return 3
	return 0 # don't freeze

func _ready() -> void:
	if body == null: body = get_parent_node_3d()
	if body && component_reader == null : component_reader = body.get_node(COMPONENT_READER)
	look.connect(func(value : bool): looked_at = value)
