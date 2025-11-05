class_name Piece extends RigidBody3D

signal found_health()
signal found_damage()
signal found_playable()
signal found_team()

## REGULAR COMPONENT NAMES
const STANDARD_COLOR = Color.WHITE_SMOKE
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
@export var team_id : int = 0 :
	set(new_value) : set_team_id(new_value)
	get() :
		if team_component == null : return team_id
		return team_component.id
var initial_team_id : int = 0
var initial_team : Team
var initial_invert : bool = false
@export_group("Color Settings")
@export var skin : MeshInstance3D
@export var tint : Color = STANDARD_COLOR :
	set(new_tint): 
		tint = new_tint
		set_color()
@export var inherit_color : bool = true
@export var block_color : bool = false

var health_points : float :
	get() :
		if health_component == null : return health_points
		return health_component.health_points
var damage_points : float :
	get() :
		if damage_points == null : return damage_points
		return damage_component.damage_points
var is_playable : bool :
	get () :
		if playable_component == null : return false
		return true
var is_playing : bool :
	get() :
		if !is_playable || ( is_playable && ( playable_component.is_deceased || !playable_component.active ) ) : return false
		return true
var is_alive : bool :
	get() :
		if health_component == null : return false
		return health_component.alive
var initial_coordinates : Vector2i = Vector2i.ZERO
var current_coordinates : Vector2i :
	get() :
		if playable_component == null : return Vector2i.ZERO
		return playable_component.coordinates
var mother : PieceGenerator


@export_group("Set Components") 
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
@export_category("Auto Population Settings")
## Auto populate using the given body and finding their children by class name
@export var populate : bool = true
## Auto populate using specific names for components
@export var custom_names : bool = true
@export_group("Custom name settings")
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
				health_component = node ; found_health.emit() ; return node
	return null

func read_damage_component() -> DamageComponent :
	for node in get_children(): 
		if node is DamageComponent:
			if !custom_names || (custom_names && node.name == damage_name):
				damage_component = node ; found_damage.emit() ; return node
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
				team_component = node ; found_team.emit() ; return node
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
				playable_component = node ; found_playable.emit() ; return node
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


func set_initial_coordinates( new_coords : Vector2i = initial_coordinates ) :
	if playable_component == null : return
	playable_component.coordinates = new_coords

func set_coordinates(new_coords : Vector2i, connect : bool, set_position : bool):
	if playable_component == null : return
	playable_component.set_coordinates(new_coords, connect, set_position)
	
func set_team_id( new_id : int = initial_team_id ): 
	if team_component == null : return
	team_component.id = new_id

func set_team( new_team : Team = initial_team ):
	if team_component == null : return
	new_team.apply(self)

func set_color(new_tint : Color = tint):
	if skin == null || block_color : return
	var new_skin = StandardMaterial3D.new()
	new_skin.albedo_color = new_tint
	skin.set_surface_override_material(0, new_skin)

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
	
	if initial_team : found_team.connect(set_team)
	else : if initial_team_id : found_team.connect(set_team_id)
	found_playable.connect(func() :
		set_initial_coordinates()
		if initial_invert : 
			playable_component.invert_attack_axis = true
			playable_component.invert_movement_axis = true )
	
	if populate: read_components()
	if !inherit_color : set_color(tint)
