class_name SelectableComponent extends Node3D

signal select(new_selection_value : bool, was_a_player_selection : Manipulator)

var current_manipulator : Manipulator
var _manipulator_list : Array[Manipulator] = []

@export var body : Piece
@export var active : bool = true
@export var freeze : bool = false
@export var selected : bool = false :
	set(new_selection_value):
		if !active || body == null || new_selection_value == selected : return
		selected = new_selection_value
		if !outline_when_selected || outline: outline.visible = false
		if selected:
			if current_manipulator && !_manipulator_list.has(current_manipulator):
				_manipulator_list.append(current_manipulator)
			if outline_when_selected && outline:
				if !current_manipulator || (current_manipulator
				&& _manipulator_list.has(current_manipulator)) : outline.visible = true
		if !selected && current_manipulator && _manipulator_list.has(current_manipulator):
			_manipulator_list.remove_at(_manipulator_list.find(current_manipulator))
			current_manipulator = null
		if !freeze || body.freezable_component == null: return
		body.freezable_component.freeze.emit(selected, current_manipulator)
@export var outline_when_selected : bool = true
@export var outline : MeshInstance3D

func _ready():
	if body == null: body = get_parent_node_3d()
	select.connect(func(new_selection_value : bool, was_a_player_selection : Manipulator) : 
		current_manipulator = was_a_player_selection
		selected = new_selection_value)
