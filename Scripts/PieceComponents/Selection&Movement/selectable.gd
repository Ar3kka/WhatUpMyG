class_name SelectableComponent extends Node3D

signal just_selected
signal just_deselected

var current_manipulator : Manipulator
var _manipulator_list : Array[Manipulator] = []

## The piece that this component belongs to.
@export var body : Piece
## Whether or not this component is active and functional.
@export var active : bool = true
## Freeze when selected.
@export var freeze : bool = false
var selected : bool = false :
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
@export_group("Outline Settings")
## Whenever this piece is selected, outline it using the outline MeshInstance3D set below
@export var outline_when_selected : bool = true
## The outline itself.
@export var outline : MeshInstance3D

func select(new_selection_value : bool, was_a_player_selection : Manipulator) :
	current_manipulator = was_a_player_selection
	selected = new_selection_value
	if selected : just_selected.emit() ; return
	just_deselected.emit()

func _ready():
	if body == null: body = get_parent_node_3d()
