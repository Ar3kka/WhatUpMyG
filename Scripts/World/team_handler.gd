class_name Team extends Node3D

@export var team_name : String = ""
@export var id : int = 0
@export var uniform_color : bool = true
@export var team_color : Color = Color.WHITE_SMOKE
@export var pieces_location : Node3D
var pieces : Array[Piece] = []

func _ready() -> void:
	update_pieces()
	apply_color()

func update_pieces(restart : bool = true) :
	if pieces_location == null : return
	if restart : pieces = []
	for child in pieces_location.get_children() :
		if child is Piece && child.team_id == id : pieces.append(child)

func apply_color():
	for piece in pieces : 
		piece.set_color(team_color)
