class_name SelectableComponent extends Node3D

const FREEZABLE_NODE = "Freezable"
const DRAGGABLE_NODE = "Draggable"

signal select(new_selection_value : bool, was_a_player_selection : bool)

var player_selection : bool = true

@export var body : RigidBody3D
@export var active : bool = true
@export var freeze : bool = false
@export var selected : bool = false :
	set(new_selection_value):
		if !active || body == null || new_selection_value == selected : return
		selected = new_selection_value
		if Outline || !outline_when_selected: Outline.visible = false
		if selected:
			if Outline && outline_when_selected: Outline.visible = true
			print("I'm selected now, happy?")
		else: print("I've been deselected, let's fucking go")
		if !freeze : return
		var freezable_component : FreezableComponent = body.get_node(FREEZABLE_NODE)
		if freezable_component != null: freezable_component.freeze.emit(selected, player_selection)
@export var outline_when_selected : bool = true
@export var Outline : MeshInstance3D

func _ready():
	if body == null: body = get_parent_node_3d()
	select.connect(func(new_selection_value : bool, was_a_player_selection : bool) : 
		selected = new_selection_value
		player_selection = was_a_player_selection)
