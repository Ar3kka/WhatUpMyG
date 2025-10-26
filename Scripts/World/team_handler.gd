class_name Team extends Node3D

const SCENE : PackedScene = preload("res://Scenes/World/team.tscn")

@export var team_name : String = ""
@export var id : int = 0
@export var uniform_color : bool = true
@export var team_color : Color = Color.WHITE_SMOKE
@export var invert_axis : bool = false
@export var update_on_generation : bool = false
@export var pieces_location : PieceGenerator
var pieces : Array[Piece] = []

func _ready() -> void:
	pieces_location.generated_piece.connect(func() :
		if !update_on_generation : return
		update_pieces()
		apply_color() )

func instantiate() -> Team : return SCENE.instantiate()

func apply(piece : Piece) :
	piece.initial_team = self
	if piece.inherit_color : piece.set_color(team_color)
	piece.initial_team_id = id
	piece.initial_invert = invert_axis
	piece.team_id = id

func update_pieces(restart : bool = true) :
	if pieces_location == null : return
	if restart : pieces = []
	for child in pieces_location.get_children() :
		if child is Piece && child.team_id == id : pieces.append(child)

func apply_color():
	for piece in pieces :
		piece.set_color(team_color)
