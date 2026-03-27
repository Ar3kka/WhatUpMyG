class_name Set extends Node3D

var id : int = 0
@export var set_name : String = ""
var pieces : Array[Piece] = []
var womb : PieceGenerator

func _ready() -> void :
	if womb == null : womb = PieceGenerator.new()

func add_piece( new_piece : Piece =  ) :
	pieces.append( new_piece )

func populate() :
	pass 
