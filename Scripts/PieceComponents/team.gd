class_name TeamComponent extends Node3D

signal change_team(player_team : int, new_team_id : int)

@export var body : RigidBody3D
@export var active : bool = true
@export var team : int = 1
var observer_team : int = 0

func _ready():
	if body == null: body = get_parent_node_3d()
	change_team.connect(func(new_observer_team_id : int, new_team_id : int): 
		observer_team = new_observer_team_id
		team = new_team_id)
