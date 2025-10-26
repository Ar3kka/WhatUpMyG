class_name DamageComponent extends Node3D

const STANDARD_DAMAGE : float = 1.0
const STANDARD_EFFECT : float = 0.0
const STANDARD_MULTIPLIER : float = 1.0

@export var body : Piece
@export var active : bool = true
@export var damage_points : float = STANDARD_DAMAGE :
	get () : return ( damage_points + effect ) * multiplier
var effect : float = STANDARD_EFFECT
var multiplier : float = STANDARD_MULTIPLIER
@export var cooldown_time : float = 2.0
var playable_component : PlayableComponent :
	set(new_value) : return
	get() : return body.playable_component

func hit(health_component : HealthComponent):
	health_component.hit.emit(self)

func _on_ready():
	if body == null : body = get_parent_node_3d()
