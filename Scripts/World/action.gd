class_name Action extends Node

var has_attacked : bool :
	get() : return attacker && attacked && attacked_from && attacked_to
var attacker : Piece
var attacked : Piece
var attacked_from : Tile
var attacked_to : Tile

var has_moved : bool :
	get() : return moved && moved_from && moved_to
var moved : Piece
var moved_from : Tile
var moved_to : Tile

var has_affected : bool :
	get() : return affected && affected_by && affected_with
var affected_by
var affected_with
var affected

func attack(new_attacker : Piece, attacked_piece : Piece, from : Tile, to : Tile) :
	attacker = new_attacker
	attacked = attacked_piece
	attacked_from = from
	attacked_to = to
	
func move(moved_piece : Piece, from : Tile, to : Tile) :
	moved = moved_piece
	moved_from = from
	moved_to = to

func effect(effect, receiver, perpretator) :
	affected_with = effect
	affected_by = perpretator
	affected = receiver
