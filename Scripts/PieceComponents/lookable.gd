class_name LookableComponent extends Node3D

const FREEZABLE_NODE = "Freezable"
const SELECTABLE_NODE = "Selectable"
const DRAGGABLE_NODE = "Draggable"

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
		var freeze_result : bool = false
		var freezable_component : FreezableComponent = body.get_node(FREEZABLE_NODE)
		if freezable_component == null || _freeze() == 0: return
		if freeze_on_look: freeze_result = true # freeze when looked
		if freeze_if_selectable:
			var selectable_component : SelectableComponent = body.get_node(SELECTABLE_NODE)
			if selectable_component != null && selectable_component.active : freeze_result = true
		if freeze_if_draggable: # freeze when object being looked is selectable
			var draggable_component : DraggableComponent = body.get_node(DRAGGABLE_NODE)
			if draggable_component != null && draggable_component.active: freeze_result = true
		if !looked_at: #print(body, ": I'm being looked at and it makes me uncomfortable: ", looked_at)
		#else:
			freeze_result = false 
			#print(body, ": HELL YEAH IT STOPPED, THANK YOU MY GOD")
		freezable_component.freeze.emit(freeze_result, true)

func _freeze() -> int:
	if freeze_on_look: return 1
	if freeze_if_selectable: return 2
	if freeze_if_draggable: return 3
	return 0 # don't freeze

func _ready() -> void:
	if body == null: body = get_parent_node_3d()
	look.connect(func(value : bool): looked_at = value)
