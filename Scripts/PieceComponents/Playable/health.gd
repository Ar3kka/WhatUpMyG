class_name HealthComponent extends Node3D

signal hit(damage_component : DamageComponent)
signal death()

var global := GeneralKnowledge.new()

@export var active : bool = true
@export var body : Piece
@export var max_health : float = global.STANDARD_MAX_HEALTH
@export var health_points : float = global.STANDARD_MAX_HEALTH :
	get() : 
		var final_hp : float = ( health_points + effect ) * multiplier
		if final_hp > max_health : final_hp = max_health
		return final_hp
var effect : float = global.STANDARD_EFFECT
var multiplier : float = global.STANDARD_MULTIPLIER
var alive : bool :
	set(new_value) : return
	get() :
		return health_points > 0
@export var invincible_time : float = 2.0
var invincible : bool = false
var playable_component : PlayableComponent :
	set(new_value) : return
	get() : 
		if body == null : return playable_component
		return body.playable_component

func _on_health_area_area_entered(area: Area3D):
	return
	if area.get_parent_node_3d().body == body: return

func _on_ready():
	if body == null : body = get_parent_node_3d()
	hit.connect( func(damage_component : DamageComponent):
		health_points -= damage_component.damage_points
		if alive : return
		if damage_component.playable_component : damage_component.playable_component.kill.emit(playable_component)
		death.emit() )
