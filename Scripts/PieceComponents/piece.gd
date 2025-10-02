class_name Piece extends RigidBody3D

## REGULAR COMPONENT NAMES
const HEALTH_COMPONENT = "Health"
const DAMAGE_COMPONENT = "Damage"
const DRAGGABLE_COMPONENT = "Draggable"
const FREEZABLE_COMPONENT = "Freezable"
const LOOKABLE_COMPONENT = "Lookable"
const SELECTABLE_COMPONENT = "Selectable"
const TEAM_COMPONENT = "Team"
const ROTATABLE_COMPONENT = "Rotatable"
const SNAPPABLE_COMPONENT = "Snappable"
const PLAYABLE_COMPONENT = "Playable"

@export var active : bool = true
var manipulator : Manipulator

## The component that makes this 3d rigidbody have health
@export var health_component : HealthComponent :
	set(new_health):
		if !active: return
		health_component = new_health
## The component that makes this 3d rigidbody have and deal damage
@export var damage_component : DamageComponent :
	set(new_damage):
		if !active: return
		damage_component = new_damage
## The component that makes this 3d rigidbody be lookable and interactable by the mouse pointer (player)
@export var lookable_component : LookableComponent :
	set(new_lookable):
		if !active: return
		lookable_component = new_lookable
## The component that makes this 3d rigidbody have a set team (player assigned)
@export var team_component : TeamComponent :
	set(new_team):
		if !active: return
		team_component = new_team
## The component that makes this 3d rigidbody selectable either by the player or environment
@export var selectable_component : SelectableComponent :
	set(new_selectable):
		if !active: return
		selectable_component = new_selectable
## The component that makes this 3d rigidbody be frozen by the player or environment
@export var freezable_component : FreezableComponent :
	set(new_freezable):
		if !active: return
		freezable_component = new_freezable
## The component that makes this 3d rigidbody be draggable by the player or environment
@export var draggable_component : DraggableComponent :
	set(new_draggable):
		if !active: return
		draggable_component = new_draggable
## The component that makes this 3d rigidbody be rotatable by the player or environment
@export var rotatable_component : RotatableComponent :
	set(new_rotatable):
		if !active: return
		rotatable_component = new_rotatable
@export var snappable_component : SnappableComponent :
	set(new_snappable):
		if !active: return
		snappable_component = new_snappable
@export var playable_component : PlayableComponent :
	set(new_playable):
		if !active: return
		playable_component = new_playable

## Auto populate using the given body and finding their children by class name
@export var populate : bool = true
## Auto populate using specific names for components
@export var custom_names : bool = true
## Custom name for the health component for auto population
@export var health_name : String = HEALTH_COMPONENT
## Custom name for the damage component for auto population
@export var damage_name : String = DAMAGE_COMPONENT
## Custom name for the lookable component for auto population
@export var lookable_name : String = LOOKABLE_COMPONENT
## Custom name for the team component for auto population
@export var team_name : String = TEAM_COMPONENT
## Custom name for the selectable component for auto population
@export var selectable_name : String = SELECTABLE_COMPONENT
## Custom name for the freezable component for auto population
@export var freezable_name : String = FREEZABLE_COMPONENT
## Custom name for the draggable component for auto population
@export var draggable_name : String = DRAGGABLE_COMPONENT
## Custom name for the rotatable component for auto population
@export var rotatable_name : String = ROTATABLE_COMPONENT
## Custom name for the snappable component for auto population
@export var snappable_name : String = SNAPPABLE_COMPONENT
## Custom name for the playable component for auto population
@export var playable_name : String = PLAYABLE_COMPONENT


var components : Array[Node3D] = []

func read_health_component() -> HealthComponent :
	for node in get_children(): 
		if node is HealthComponent:
			if !custom_names || (custom_names && node.name == health_name):
				health_component = node ; return node
	return null

func read_damage_component() -> DamageComponent :
	for node in get_children(): 
		if node is DamageComponent:
			if !custom_names || (custom_names && node.name == damage_name):
				damage_component = node ; return node
	return null
	
func read_lookable_component() -> LookableComponent :
	for node in get_children(): 
		if node is LookableComponent: 
			if !custom_names || (custom_names && node.name == lookable_name):
				lookable_component = node ; return node
	return null
	
func read_team_component() -> TeamComponent :
	for node in get_children(): 
		if node is TeamComponent:
			if !custom_names || (custom_names && node.name == team_name):
				team_component = node ; return node
	return null
	
func read_selectable_component() -> SelectableComponent :
	for node in get_children(): 
		if node is SelectableComponent: 
			if !custom_names || (custom_names && node.name == selectable_name):
				selectable_component = node ; return node
	return null
	
func read_freezable_component() -> FreezableComponent :
	for node in get_children(): 
		if node is FreezableComponent: 
			if !custom_names || (custom_names && node.name == freezable_name):
				freezable_component = node ; return node
	return null

func read_draggable_component() -> DraggableComponent :
	for node in get_children(): 
		if node is DraggableComponent: 
			if !custom_names || (custom_names && node.name == draggable_name):
				draggable_component = node ; return node
	return null

func read_rotatable_component() -> RotatableComponent :
	for node in get_children(): 
		if node is RotatableComponent: 
			if !custom_names || (custom_names && node.name == rotatable_name):
				rotatable_component = node ; return node
	return null
	
func read_snappable_component() -> SnappableComponent :
	for node in get_children(): 
		if node is SnappableComponent: 
			if !custom_names || (custom_names && node.name == snappable_name):
				snappable_component = node ; return node
	return null

func read_playable_component() -> PlayableComponent :
	for node in get_children(): 
		if node is PlayableComponent: 
			if !custom_names || (custom_names && node.name == playable_name):
				playable_component = node ; return node
	return null

func _populate_components_array(restart : bool):
	if !active: return
	if restart : components = []
	
	if health_component && !components.has(health_component) : 
		components.append(health_component)
		
	if damage_component && !components.has(damage_component) : 
		components.append(damage_component)
	
	if lookable_component && !components.has(lookable_component) : 
		components.append(lookable_component)
	
	if team_component && !components.has(team_component) : 
		components.append(team_component)
	
	if selectable_component && !components.has(selectable_component) : 
		components.append(selectable_component)
	
	if freezable_component && !components.has(freezable_component) : 
		components.append(freezable_component)
	
	if draggable_component && !components.has(draggable_component) : 
		components.append(draggable_component)
	
	if rotatable_component && !components.has(rotatable_component) : 
		components.append(rotatable_component)
	
	if snappable_component && !components.has(snappable_component) : 
		components.append(snappable_component)
		
	if snappable_component && !components.has(playable_component) : 
		components.append(snappable_component)

func read_components():
	if !active: return
	read_health_component()
	read_damage_component()
	read_lookable_component()
	read_team_component()
	read_selectable_component()
	read_freezable_component()
	read_draggable_component()
	read_rotatable_component()
	read_snappable_component()
	read_playable_component()
	
	_populate_components_array(false)

func _ready() -> void:
	if !active : return
	if populate: read_components()
