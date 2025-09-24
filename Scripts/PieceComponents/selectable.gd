class_name SelectableComponent extends Node3D

const COMPONENT_READER = "PieceReader"
@export var component_reader : PieceReader

signal select(new_selection_value : bool, was_a_player_selection : bool)

var player_manipulation : bool = true

@export var body : RigidBody3D
@export var active : bool = true
@export var freeze : bool = false
@export var selected : bool = false :
	set(new_selection_value):
		if !active || body == null || new_selection_value == selected : return
		selected = new_selection_value
		if !outline_when_selected || outline: outline.visible = false
		if selected && outline_when_selected && outline: outline.visible = true
		if !freeze || component_reader == null || component_reader.freezable_component == null: return
		component_reader.freezable_component.freeze.emit(selected, player_manipulation)
@export var outline_when_selected : bool = true
@export var outline : MeshInstance3D

func _ready():
	if body == null: body = get_parent_node_3d()
	if body && component_reader == null : component_reader = body.get_node(COMPONENT_READER)
	select.connect(func(new_selection_value : bool, was_a_player_selection : bool) : 
		selected = new_selection_value
		player_manipulation = was_a_player_selection)
