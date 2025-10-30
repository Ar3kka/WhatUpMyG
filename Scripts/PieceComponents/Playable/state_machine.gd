class_name StateMachine extends Node3D

signal effects_applied(effects : Array[Effect])
signal effect_applied(effect : Effect)
signal effect_unapplied(effect : Effect)

var global := GeneralKnowledge.new()

@export var active : bool = true :
	get() :
		if playable == null : return false
		return active
@export var playable : PlayableComponent
var movement_reach : ReachComponent :
	get() :
		if playable == null : return
		return playable.movement_reach
var attack_reach : ReachComponent :
	get() :
		if playable == null : return
		return playable.attack_reach
var health_component : HealthComponent :
	get() :
		if playable == null : return
		return playable.health_component
var damage_component : DamageComponent :
	get() :
		if playable == null : return
		return playable.damage_component

var effects : Array[Effect] = []
var specials : Array[Node3D] = []

var health_effect : float = global.STANDARD_EFFECT :
	set(new_value) :
		if health_component == null : return
		health_effect = new_value
		health_component.effect += health_effect
var damage_effect : float = global.STANDARD_EFFECT :
	set(new_value) :
		if damage_component == null : return
		damage_effect = new_value
		damage_component.effect += damage_effect

var health_multiplier : float = global.STANDARD_MULTIPLIER :
	set(new_value) :
		if health_component == null : return
		health_multiplier = new_value
		health_component.multiplier += health_multiplier
var damage_multiplier : float = global.STANDARD_MULTIPLIER :
	set(new_value) :
		if damage_component == null : return
		damage_multiplier = new_value
		damage_component.multiplier += damage_multiplier

var movement_depth : Vector2i = global.STANDARD_EFFECT_VECTOR :
	set(new_value) :
		if movement_reach == null : return
		movement_depth = new_value
		movement_reach.depth_effect += movement_depth
var movement_horizontal : Vector2i = global.STANDARD_EFFECT_VECTOR :
	set(new_value) :
		if movement_reach == null : return
		movement_horizontal = new_value
		movement_reach.horizontal_effect += movement_horizontal
var movement_front_diagonal : Vector2i = global.STANDARD_EFFECT_VECTOR :
	set(new_value) :
		if movement_reach == null : return
		movement_front_diagonal = new_value
		movement_reach.frontal_diagonal_effect += movement_front_diagonal
var movement_rear_diagonal : Vector2i = global.STANDARD_EFFECT_VECTOR :
	set(new_value) :
		if movement_reach == null : return
		movement_rear_diagonal = new_value
		movement_reach.rear_diagonal_effect += movement_rear_diagonal

var movement_depth_multiplier : Vector2i = global.STANDARD_MULTIPLIER_VECTOR :
	set(new_value) :
		if movement_reach == null : return
		movement_depth_multiplier = new_value
		movement_reach.depth_multiplier += movement_depth_multiplier
var movement_horizontal_multiplier : Vector2i = global.STANDARD_MULTIPLIER_VECTOR :
	set(new_value) :
		if movement_reach == null : return
		movement_horizontal_multiplier = new_value
		movement_reach.horizontal_multiplier += movement_horizontal_multiplier
var movement_front_diagonal_multiplier : Vector2i = global.STANDARD_MULTIPLIER_VECTOR :
	set(new_value) :
		if movement_reach == null : return
		movement_front_diagonal_multiplier = new_value
		movement_reach.frontal_diagonal_multiplier += movement_front_diagonal_multiplier
var movement_rear_diagonal_multiplier : Vector2i = global.STANDARD_MULTIPLIER_VECTOR :
	set(new_value) :
		if movement_reach == null : return
		movement_rear_diagonal_multiplier = new_value
		movement_reach.rear_diagonal_multiplier += movement_rear_diagonal_multiplier

var attack_depth : Vector2i = global.STANDARD_EFFECT_VECTOR :
	set(new_value) :
		if attack_reach == null : return
		attack_depth = new_value
		attack_reach.depth_effect += attack_depth
var attack_horizontal : Vector2i = global.STANDARD_EFFECT_VECTOR :
	set(new_value) :
		if attack_reach == null : return
		attack_horizontal = new_value
		attack_reach.horizontal_effect += attack_horizontal
var attack_front_diagonal : Vector2i = global.STANDARD_EFFECT_VECTOR :
	set(new_value) :
		if attack_reach == null : return
		attack_front_diagonal = new_value
		attack_reach.depth_effect += attack_front_diagonal
var attack_rear_diagonal : Vector2i = global.STANDARD_EFFECT_VECTOR :
	set(new_value) :
		if attack_reach == null : return
		attack_rear_diagonal = new_value
		attack_reach.depth_effect += attack_rear_diagonal

var attack_depth_multiplier : Vector2i = global.STANDARD_MULTIPLIER_VECTOR :
	set(new_value) :
		if attack_reach == null : return
		attack_depth_multiplier = new_value
		attack_reach.depth_multiplier += attack_depth_multiplier
var attack_horizontal_multiplier : Vector2i = global.STANDARD_MULTIPLIER_VECTOR :
	set(new_value) :
		if attack_reach == null : return
		attack_horizontal_multiplier = new_value
		attack_reach.horizontal_multiplier += attack_horizontal_multiplier
var attack_front_diagonal_multiplier : Vector2i = global.STANDARD_MULTIPLIER_VECTOR :
	set(new_value) :
		if attack_reach == null : return
		attack_front_diagonal_multiplier = new_value
		attack_reach.frontal_diagonal_multiplier += attack_front_diagonal_multiplier
var attack_rear_diagonal_multiplier : Vector2i = global.STANDARD_MULTIPLIER_VECTOR :
	set(new_value) :
		if attack_reach == null : return
		attack_rear_diagonal_multiplier = new_value
		attack_reach.rear_diagonal_multiplier += attack_rear_diagonal_multiplier

func _ready() -> void:
	if playable == null : playable = get_parent_node_3d()

func apply_effects():
	if effects.is_empty() : return
	for effect in effects:
		apply_effect(effect)
	effects_applied.emit(effects)

func clear(remove_permanent : bool = false) : 
	for effect in effects :
		unapply_effect(effect)

func unapply_effect( effect : Effect , remove : bool = true, force : bool = false ):
	if !active || ( effect.is_permanent && !force ) : return 
		
	health_effect -= effect.health_effect
	health_multiplier -= effect.health_multiplier
	damage_effect -= effect.damage_effect
	damage_multiplier -= effect.damage_multiplier
	movement_depth -= effect.movement_depth
	movement_depth_multiplier -= effect.movement_depth_multiplier
	movement_horizontal -= effect.movement_horizontal
	movement_horizontal_multiplier -= effect.movement_horizontal_multiplier
	movement_front_diagonal -= effect.movement_front_diagonal
	movement_front_diagonal_multiplier -= effect.movement_front_diagonal_multiplier
	movement_rear_diagonal -= effect.movement_rear_diagonal
	movement_rear_diagonal_multiplier -= effect.movement_rear_diagonal_multiplier
	attack_depth -= effect.attack_depth
	attack_depth_multiplier -= effect.attack_depth_multiplier
	attack_horizontal -= effect.attack_horizontal
	attack_horizontal_multiplier -= effect.attack_horizontal_multiplier
	attack_front_diagonal -= effect.attack_front_diagonal
	attack_front_diagonal_multiplier -= effect.attack_front_diagonal_multiplier
	attack_rear_diagonal -= effect.attack_rear_diagonal
	attack_rear_diagonal_multiplier -= effect.attack_rear_diagonal_multiplier
	
	effect.unapply()
	effect_unapplied.emit(effect)
	if remove : remove_effect(effect)

func apply_effect( effect : Effect, add : bool = true, force : bool = false):
	if !active || !effect.active || ( !force && effect.is_applied ) : return
	
	health_effect += effect.health_effect
	health_multiplier += effect.health_multiplier
	damage_effect += effect.damage_effect
	damage_multiplier += effect.damage_multiplier
	movement_depth += effect.movement_depth
	movement_depth_multiplier += effect.movement_depth_multiplier
	movement_horizontal += effect.movement_horizontal
	movement_horizontal_multiplier += effect.movement_horizontal_multiplier
	movement_front_diagonal += effect.movement_front_diagonal
	movement_front_diagonal_multiplier += effect.movement_front_diagonal_multiplier
	movement_rear_diagonal += effect.movement_rear_diagonal
	movement_rear_diagonal_multiplier += effect.movement_rear_diagonal_multiplier
	attack_depth += effect.attack_depth
	attack_depth_multiplier += effect.attack_depth_multiplier
	attack_horizontal += effect.attack_horizontal
	attack_horizontal_multiplier += effect.attack_horizontal_multiplier
	attack_front_diagonal += effect.attack_front_diagonal
	attack_front_diagonal_multiplier += effect.attack_front_diagonal_multiplier
	attack_rear_diagonal += effect.attack_rear_diagonal
	attack_rear_diagonal_multiplier += effect.attack_rear_diagonal_multiplier
	
	effect.apply(self)
	effect_applied.emit(effect)
	if add : add_effect(effect)

func add_effect(new_effect : Effect, apply : bool = false, clear : bool = false) :
	if effects.has(new_effect) : return
	if clear : clear()
	if apply : apply_effect(new_effect)
	effects.append(new_effect)

func remove_effect(effect : Effect) :
	effects.erase(effect)

func apply_specials() :
	for special in specials :
		if special.has_method(global.SPECIAL_APPLY) : special.apply()

func apply_special( index : int = 0 ) :
	if specials.is_empty() : return
	var special = specials[index]
	if special != null && special.has_method(global.SPECIAL_APPLY) : special.apply()

func apply_specific_special( special ) :
	if special.has_method(global.SPECIAL_APPLY) : special.apply()
