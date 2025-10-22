class_name TeamComponent extends Node3D

signal change_team(player_team : int, new_team_id : int)

@export var body : Piece
@export var active : bool = true
## The team ID for the given body, if set to 0, this object will count as teamless and any observer will be able to interact with it.
@export var id : int = 0
var observer_team_id : int = 0

func _ready():
	if body == null: body = get_parent_node_3d()
	change_team.connect(func(new_observer_team_id : int, new_team_id : int): 
		observer_team_id = new_observer_team_id
		id = new_team_id)

func is_observed_by_same_team() -> bool:
	return active && (observer_team_id == id || id == 0)
