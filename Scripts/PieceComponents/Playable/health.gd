class_name HealthComponent extends Node3D

signal hit(damage_component : DamageComponent)
signal death()

var global := GeneralKnowledge.new()

@export var active : bool = true
@export var body : Piece
@export var max_health : float = global.STANDARD_MAX_HEALTH
@export var health_points : float = max_health :
	get() : 
		var final_hp : float = ( health_points + effect ) * multiplier
		return final_hp
var effect : float = global.STANDARD_EFFECT
var multiplier : float = global.STANDARD_MULTIPLIER
var alive : bool :
	get() :
		return health_points > 0
@export var invincible_time : float = 2.0
var invincible : bool = false
var playable_component : PlayableComponent :
	get() : 
		if body == null : return playable_component
		return body.playable_component

func set_health(new_health : float, addition : bool = true, ignore_max_health : bool = false):
	if !addition : health_points = 0
	health_points += new_health
	if !ignore_max_health && health_points > max_health : health_points = max_health

func _on_ready():
	if body == null : body = get_parent_node_3d()
	hit.connect( func(damage_component : DamageComponent):
		health_points -= damage_component.damage_points
		if alive : return
		if damage_component.playable_component : damage_component.playable_component.kill.emit(playable_component)
		death.emit() )
