class_name SelectableComponent extends Node3D

signal select(new_selection_value : bool, was_a_player_selection : bool)

var player_manipulation : bool = true

@export var body : Piece
@export var active : bool = true
@export var freeze : bool = false
@export var selected : bool = false :
	set(new_selection_value):
		if !active || body == null || new_selection_value == selected : return
		selected = new_selection_value
		if !outline_when_selected || outline: outline.visible = false
		if selected && outline_when_selected && outline: outline.visible = true
		if !freeze || body.freezable_component == null: return
		body.freezable_component.freeze.emit(selected, player_manipulation)
@export var outline_when_selected : bool = true
@export var outline : MeshInstance3D

func _ready():
	if body == null: body = get_parent_node_3d()
	select.connect(func(new_selection_value : bool, was_a_player_selection : bool) : 
		selected = new_selection_value
		player_manipulation = was_a_player_selection)
