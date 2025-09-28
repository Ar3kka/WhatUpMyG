class_name LookableComponent extends Node3D

signal look(new_look : bool, manipulator : Manipulator)

@export var body : Piece
@export var active : bool = true
@export var freeze_on_look : bool = false
@export var freeze_if_selectable : bool = true
@export var freeze_if_draggable : bool = false

var observed_by : Manipulator
var _observers_list : Array[Manipulator] = []

var looked_at : bool = false :
	set(new_value):
		if !active || body == null || looked_at == new_value : return
		looked_at = new_value
		if looked_at && observed_by && !_observers_list.has(observed_by): 
				_observers_list.append(observed_by)
		else: if !looked_at && observed_by:
			_observers_list.erase(observed_by)
			observed_by = null
		
		if (body.freezable_component == null || _get_freeze_type() == 0): return
		
		var freeze_result : bool = false
		
		if ((freeze_on_look) || # freeze when object is set to freeze on look
		(freeze_if_selectable # freeze when object being looked is selectable
		&& body.selectable_component
		&& body.selectable_component.active) ||
		(freeze_if_draggable # freeze when object being looked is draggable
		&& body.draggable_component
		&& body.draggable_component.active)):
			freeze_result = true
		
		if !looked_at: 
			freeze_result = false 
		
		body.freezable_component.freeze.emit(freeze_result, observed_by)

func _get_freeze_type() -> int:
	if freeze_on_look: return 1
	if freeze_if_selectable: return 2
	if freeze_if_draggable: return 3
	return 0 # don't freeze

func _ready() -> void:
	if body == null: body = get_parent_node_3d()
	look.connect(func(new_look : bool, manipulator : Manipulator): 
		observed_by = manipulator
		looked_at = new_look)
