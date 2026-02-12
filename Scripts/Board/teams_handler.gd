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
		var index : int = 0
		for child in get_children() : if child is Team : child.index = index; array.append(child); index += 1
		return array

func get_random_team() -> Team :
	return get_child(god.randi_range(0, get_children().size() - 1))

func get_team_by_index(index : int = 0, loop : bool = true) -> Team :
	if teams.size() < 1 : return
	if index > teams.size() - 1 : 
		index = teams.size() - 1
		if loop : index = 0 
	return teams[index]

func get_team(id : int = 0, get_default : bool = false) -> Team :
	for team in teams : if team.id == id : return team
	else : if get_default && teams.size() > 0 : return teams[0]
	return

func get_team_by_name(team_name : String = "") -> Team :
	for team in teams : if team.team_name == team_name : return team
	return

func add_team(team_id : int = teams.size() + 1, team_name : String = "", team_color : Color = Color(god.randf_range(0, 255), god.randf_range(0, 255), god.randf_range(0, 255), 100)) -> Team:
	if get_team(team_id) : return
	var new_team : Team = Team.new().instantiate()
	new_team.handler = self
	new_team.id = team_id
	new_team.team_name = team_name
	new_team.team_color = team_color
	new_team.pieces_location = piece_generator
	add_child(new_team)
	return new_team
