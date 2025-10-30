class_name GeneralKnowledge extends Node

const SPECIAL_APPLY : String = "apply"

const STANDARD_FREEZE_MODE = RigidBody3D.FREEZE_MODE_KINEMATIC
const NO_PHYSICS_FREEZE_MODE = RigidBody3D.FREEZE_MODE_KINEMATIC

const STANDARD_DAMAGE : float = 1.0
const STANDARD_MAX_HEALTH : float = 1.0

const STANDARD_GLOBAL_POSITION : Vector3 = Vector3.ZERO
const STANDARD_GLOBAL_NEGATIVE : float = -1
const STADARD_NEGATIVE_VECTOR : Vector3 = Vector3(STANDARD_GLOBAL_NEGATIVE, STANDARD_GLOBAL_NEGATIVE, STANDARD_GLOBAL_NEGATIVE)

const STANDARD_EFFECT : float = 0.0
const STANDARD_EFFECT_VECTOR : Vector2i = Vector2i(STANDARD_EFFECT, STANDARD_EFFECT)

const STANDARD_MULTIPLIER : float = 1.0
const STANDARD_MULTIPLIER_VECTOR : Vector2i = Vector2i(STANDARD_MULTIPLIER, STANDARD_MULTIPLIER)

const HORIZONTAL_LEFT : Vector2i = Vector2i(0, 1)
const HORIZONTAL_RIGHT : Vector2i = Vector2i(0, -1)
const DEPTH_FRONT : Vector2i = Vector2i(1, 0)
const DEPTH_REAR : Vector2i = Vector2i(-1, 0)
const DIAGONAL_FRONTAL_LEFT : Vector2i = Vector2i(1, 1)
const DIAGONAL_FRONTAL_RIGHT : Vector2i = Vector2i(1, -1)
const DIAGONAL_REAR_LEFT : Vector2i = Vector2i(-1, 1)
const DIAGONAL_REAR_RIGHT : Vector2i = Vector2i(-1, -1)

func is_even(number : int) -> bool :
	return number % 2 == 0

func round_to_decimal(number, digits : int = 2):
	return round( number * pow( 10.0, digits ) ) / pow( 10.0, digits )

func instantiate(scene : PackedScene) -> Node3D :
	return scene.instantiate()
