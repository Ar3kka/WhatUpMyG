class_name Catalyst extends Node3D

@export var tile : Tile
var playable : PlayableComponent :
	get() :
		if tile == null || !tile.has_playable : return
		return tile.playable_piece
var state_machine : StateMachine :
	get() :
		if playable == null : return
		return playable.state_machine
var effects : Array[Effect] = []

func _ready() -> void:
	if tile == null : tile = get_parent_node_3d()

func apply_effects(playable_piece : PlayableComponent = playable):
	var machine = playable_piece.state_machine
	if machine == null : return
