class_name SetHandler extends Node3D

@export var board : Board

const premade_set_names : Array[String] = ["default", "classic", "clone"]
var premade_sets : Array = [DEFAULT, CLASSIC, CLONE]

var sets : Array[PieceSet] = []

var DEFAULT
var CLASSIC : SetClassic
var CLONE : SetClone

var miracle : RandomNumberGenerator

func _ready() -> void :
	if board == null : board = get_parent_node_3d()
	if board is Board : miracle = board.miracle
	_set_premades()

func _set_premades( default : Variant = CLASSIC ) :
	CLASSIC = SetClassic.new()
	CLONE = SetClone.new()
	DEFAULT = CLASSIC
	premade_sets = [DEFAULT, CLASSIC, CLONE]

func get_set_by_name( set_name : String = "", get_default : bool = false ) -> Variant :
	var set_index : int = premade_set_names.find(set_name)
	if set_index >= 0 : return premade_sets[set_index]
	if DEFAULT != null && ( premade_sets.is_empty() || get_default ) : return DEFAULT
	return

func generate_by_index( index : int = 0 ) -> PieceSet :
	if premade_sets.is_empty() : return
	if index > premade_sets.size() - 1 || index < 0 : index = 0
	var premade_set = premade_sets[index]
	if !premade_set.has_method("generate") : return
	var final_set : PieceSet = premade_set.generate()
	return final_set

func generate( set_name : String = "", get_default : bool = false ) -> PieceSet :
	if premade_sets.is_empty() : return
	var premade_set = get_set_by_name( set_name, get_default )
	if premade_set == null || !premade_set.has_method("generate") : return
	var final_set : PieceSet = premade_set.generate()
	return final_set

func populate_by_index( piece_set : PieceSet, index : int = 0 ) -> PieceSet :
	if premade_sets.is_empty() : return
	if index >= premade_sets.size() || index < 0 : index = 0
	var premade_set = premade_sets[index]
	if !premade_set.has_method("populate") : return
	premade_set.populate( piece_set )
	return piece_set

func populate( piece_set : PieceSet, set_name : String = "", get_default : bool = false ) -> PieceSet :
	var premade_set = get_set_by_name( set_name )
	if premade_set == null || !premade_set.has_method("populate") : return
	premade_set.populate( piece_set )
	return piece_set

func get_random_set() -> Variant :
	if miracle == null || DEFAULT == null : return
	if premade_sets.is_empty() : DEFAULT
	return premade_sets[randi_range(0, premade_sets.size() - 1)]
