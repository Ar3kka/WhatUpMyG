class_name SetDNA extends Node

var DEFAULT = CLASSIC

var CLASSIC := SetClassic.new()
var god : RandomNumberGenerator

func default( piece_set : PieceSet ) : 
	DEFAULT = CLASSIC
	DEFAULT.populate(piece_set)

func classic( piece_set : PieceSet ) : 
	CLASSIC = SetClassic.new()
	CLASSIC.populate(piece_set)

func get_random_set() -> Variant :
	if god == null : return
	match god.randi_range(0, 1) :
		0 : return CLASSIC
	return null
