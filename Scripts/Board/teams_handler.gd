class_name TeamsHandler extends Node3D

@export var board : Board
var default_team : Team :
	get() :
		if teams.is_empty() : return
		return teams[0]
var miracle : RandomNumberGenerator :
	get():
		if board == null : return RandomNumberGenerator.new()
		return board.miracle
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

func get_random_team( exclude : bool = false, id : int = 0 ) -> Team :
	if teams.size() <= 1 : return teams[0]
	else : if teams.size() == 2 && exclude : return get_next_team( id )
	var result_team : Team = get_child(miracle.randi_range(0, get_children().size() - 1))
	if !exclude : return result_team
	var repeat_count = 0
	while result_team.id == id && repeat_count <= 10 :
		result_team = get_child(miracle.randi_range(0, get_children().size() - 1))
		repeat_count += 1
		#print(repeat_count)
	return result_team

func get_next_team( id : int = 0 ) -> Team :
	if teams.size() < 1 : return
	var result_team : Team
	var aux_team : Team = get_team( id )
	if aux_team == null : return teams[0] 
	var final_index : int = aux_team.index + 1
	if final_index > teams.size() - 1 : final_index = 0
	result_team = teams[ final_index ]
	return result_team
	
func get_team_by_index(index : int = 0, loop : bool = true) -> Team :
	if teams.size() < 1 : return
	if index > teams.size() - 1 : 
		index = teams.size() - 1
		if loop : index = 0 
	return teams[index]

func get_team( team_data : Variant = 0, get_default : bool = true ) -> Team :
	var final_team : Team
	if team_data is String : 
		if team_data == "default" : return default_team if get_default else null
		final_team = get_team_by_name(team_data)
		if final_team == null && team_data.is_valid_int() : final_team = get_team_by_id(team_data.to_int())
	if team_data is int : 
		if team_data == 0 : return default_team if get_default else null
		final_team = get_team_by_id(team_data)
	return final_team

func get_team_by_id(id : int = 0, get_default : bool = false) -> Team :
	for team in teams : if team.id == id : return team
	if get_default && teams.size() > 0 : return teams[0]
	return

func get_team_by_name(team_name : String , get_default : bool = false) -> Team :
	for team in teams : if team.team_name == team_name : return team
	if get_default : return default_team
	return

func add_team(team_id : int = teams.size() + 1, team_name : String = "", team_color : Color = Color(miracle.randf_range(0, 255), miracle.randf_range(0, 255), miracle.randf_range(0, 255), 100)) -> Team:
	if get_team(team_id) : return
	var new_team : Team = Team.new().instantiate()
	new_team.handler = self
	new_team.id = team_id
	new_team.team_name = team_name
	new_team.team_color = team_color
	new_team.pieces_location = piece_generator
	add_child(new_team)
	return new_team
