class_name TurnHandler extends Node

signal finished_turn()
signal acted()

@export var active : bool = true
@export var board : Board
@export var randomized : bool = false
var teams_node : TeamsHandler :
	get() :
		if board == null : return
		return board.teams_node
var turn : int = 0
var action : int = 0
@export var initial_team : Team
var team : Team
var teams : Array[Team] :
	get() :
		if teams_node == null : return []
		return teams_node.teams
var global_actions : Array[Action] = []

func _ready() -> void :
	if board == null : board = get_parent()
	team = initial_team
	if team == null : team = teams[0]

func act( new_action : Action, playable : PlayableComponent, count_action : bool = false) :
	if !active : return
	global_actions.append(new_action); 
	if count_action : action += 1; acted.emit()
	print("Action [", action ,"] done by: ", playable, " Attack: ", new_action.has_attacked, " Movement: ", new_action.has_moved, " Effect: ", new_action.has_affected)
	if action >= team.actions_per_turn : pass_turn()

func can_act( manipulator : Manipulator ) -> bool :
	if !active || teams_node.get_team(manipulator.team_id) == team : return true
	return false

func pass_turn() :
	print("turn [", turn, "] ended by team: ", team) 
	turn += 1
	if randomized && teams_node.teams.size() > 2 : team = teams_node.get_random_team()
	else : team = teams_node.get_team_by_index(team.index + 1)
	print("New turn [", turn, "], new team: ", team)
	action = 0
	finished_turn.emit()
