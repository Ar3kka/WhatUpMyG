class_name TeamsHandler extends Node3D

@export var board : Board
var god : RandomNumberGenerator :
	get():
		if board == null : return RandomNumberGenerator.new()
		return board.god
var piece_generator : PieceGenerator :
	get() :
		if board == null : return
		return board.pieces_node
var teams : Array[Team] :
	get() :
		var array : Array[Team] = []
		for child in get_children() : if child is Team : array.append(child)
		return array

func get_random_team() -> Team :
	return get_child(god.randi_range(0, get_children().size() - 1))

func get_team(id : int = 0) -> Team :
	for team in teams : if team.id == id : return team
	return

func get_team_by_name(team_name : String = "") -> Team :
	for team in teams : if team.team_name == team_name : return team
	return

func add_team(team_id : int = 0, team_name : String = "", team_color : Color = Color.WHITE_SMOKE) -> Team:
	if get_team(team_id) : return
	var new_team : Team = Team.new().instantiate()
	new_team.id = team_id
	new_team.team_name = team_name
	new_team.team_color = team_color
	new_team.pieces_location = piece_generator
	add_child(new_team)
	return new_team
