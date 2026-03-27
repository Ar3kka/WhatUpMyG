class_name PieceDNA extends Node3D

var god : God
var miracle : RandomNumberGenerator :
	get() :
		if god == null : return
		return god.miracle

const TEMPLATE : PackedScene = preload("res://Scenes/Pieces/piece.tscn")

const pawn : String = "pawn" #0
const king : String = "king" #1
const queen : String = "queen" #2
const horse : String = "horse" #3
const tower : String = "tower" #4
const bishop : String = "bishop" #5

var pieces : PackedStringArray = [ pawn, king, queen, horse, tower, bishop ]

## ORIGINAL SET

const PAWN : PackedScene = preload("res://Scenes/Pieces/pawn.tscn") # 1
const KING : PackedScene = preload("res://Scenes/Pieces/king.tscn") # 2
const QUEEN : PackedScene = preload("res://Scenes/Pieces/queen.tscn") # 3
const HORSE : PackedScene = preload("res://Scenes/Pieces/horse.tscn") # 4
const TOWER : PackedScene = preload("res://Scenes/Pieces/tower.tscn") # 5
const BISHOP : PackedScene = preload("res://Scenes/Pieces/bishop.tscn") # 6

var scenes : Array[PackedScene] = [PAWN, KING, QUEEN, HORSE, TOWER, BISHOP]

var default_dna : PackedScene = PAWN

func get_dna_name( dna : PackedScene ) -> String :
	var _name : String = ""
	var index : int = -1
	for i in scenes.size() : 
		if scenes[i] == dna : index = i ; break
	if index > -1 && index <= pieces.size() - 1 : _name = pieces[index]
	return _name

func get_dna( piece : String ) -> PackedScene :
	if piece == "" : return
	return scenes[ pieces.find( piece.to_lower() ) ]

func get_random_dna() -> PackedScene :
	if miracle == null || scenes.size() < 1 : return default_dna
	return scenes[ miracle.randi_range(0, scenes.size() - 1) ]

func get_random_name() -> String :
	if miracle == null || pieces.size() < 1 : return "null"
	return pieces[ miracle.randi_range(0, pieces.size() - 1) ]

func generate_piece( piece_data : Variant, team_id : int, coordinates : Vector2i, health : float = 1 ) -> Piece :
	if piece_data is PackedScene : return generate_piece_dna(piece_data, team_id, coordinates, health)
	if piece_data is String : return generate_piece_name(piece_data, team_id, coordinates, health)
	if piece_data is int : return generate_piece_index(piece_data, team_id, coordinates, health)
	if god : god.print_lines(["ERROR : NO VALID DATA"])
	return

func generate_piece_index( piece_index : int, team_id : int, coordinates : Vector2i, health : float = 1 ) -> Piece :
	var piece : Piece = scenes[piece_index].instantiate()
	piece.initial_team_id = team_id
	piece.initial_coordinates = coordinates
	piece.initial_health = health
	return piece

func generate_piece_name( piece_name : String, team_id : int, coordinates : Vector2i, health : float = 1 ) -> Piece :
	var piece : Piece = get_dna(piece_name).instantiate()
	piece.initial_team_id = team_id
	piece.initial_coordinates = coordinates
	piece.initial_health = health
	return piece

func generate_piece_dna( piece_dna : PackedScene, team_id : int, coordinates : Vector2i, health : float = 1 ) -> Piece :
	var piece : Piece = piece_dna.instantiate()
	piece.initial_team_id = team_id
	piece.initial_coordinates = coordinates
	piece.initial_health = health
	return piece
