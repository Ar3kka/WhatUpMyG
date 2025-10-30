class_name Effect extends Node3D

signal unapplied()
signal applied()

var global := GeneralKnowledge.new()

@export var active : bool = true
@export var effect_name : String = ""
var doer : Node3D
var receiver : StateMachine
var is_applied : bool :
	get() :
		return times > 0
var is_permanent : bool = false
var times : int = 0 :
	set(new_times) :
		if new_times < 0 : new_times = 0
		times = new_times

var health_effect : float = global.STANDARD_EFFECT
var damage_effect : float = global.STANDARD_EFFECT

var health_multiplier : float = global.STANDARD_MULTIPLIER
var damage_multiplier : float = global.STANDARD_MULTIPLIER

var movement_depth : Vector2i = global.STANDARD_EFFECT_VECTOR
var movement_horizontal : Vector2i = global.STANDARD_EFFECT_VECTOR
var movement_front_diagonal : Vector2i = global.STANDARD_EFFECT_VECTOR
var movement_rear_diagonal : Vector2i = global.STANDARD_EFFECT_VECTOR

var movement_depth_multiplier : Vector2i = global.STANDARD_MULTIPLIER_VECTOR
var movement_horizontal_multiplier : Vector2i = global.STANDARD_MULTIPLIER_VECTOR
var movement_front_diagonal_multiplier : Vector2i = global.STANDARD_MULTIPLIER_VECTOR
var movement_rear_diagonal_multiplier : Vector2i = global.STANDARD_MULTIPLIER_VECTOR

var attack_depth : Vector2i = global.STANDARD_EFFECT_VECTOR
var attack_horizontal : Vector2i = global.STANDARD_EFFECT_VECTOR
var attack_front_diagonal : Vector2i = global.STANDARD_EFFECT_VECTOR
var attack_rear_diagonal : Vector2i = global.STANDARD_EFFECT_VECTOR

var attack_depth_multiplier : Vector2i = global.STANDARD_MULTIPLIER_VECTOR
var attack_horizontal_multiplier : Vector2i = global.STANDARD_MULTIPLIER_VECTOR
var attack_front_diagonal_multiplier : Vector2i = global.STANDARD_MULTIPLIER_VECTOR
var attack_rear_diagonal_multiplier : Vector2i = global.STANDARD_MULTIPLIER_VECTOR

func apply( machine : StateMachine ) :
	receiver = machine
	times += 1
	applied.emit()

func unapply() :
	receiver = null
	times -= 1
	unapplied.emit()
