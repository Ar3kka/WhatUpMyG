## Piece component that allows a piece to be playable with its own personalized reach pattern,
## this component is dependant on the piece being draggable, manipulable and snappable.
## For this component to work, the body piece has to have an active draggable component and snappable component.
class_name PlayableComponent extends Node3D

signal play(new_tile : Tile)
signal loaded_dependencies()
signal attacked(attacked_by : DamageComponent)
signal death()

## If not active, no built in components will interact with it, as if it
## didn't exist.
@export var active : bool = true :
	get() : 
		if !_has_dependencies || is_deceased : return false
		return active
## The piece this components belongs to.
@export var body : Piece
var is_deceased : bool :
	set(new_value) : return
	get() :
		if !_has_dependencies || body.health_component == null : return false
		if !body.health_component.alive : death.emit()
		return !body.health_component.alive
@export_group("Dependencies")
## The snappable component for dependency.
@export var snappable_component : SnappableComponent
## The draggable component for dependency.
@export var draggable_component : DraggableComponent
@export var movement_reach : ReachComponent
@export var attack_reach : ReachComponent
@export var health_component : HealthComponent :
	set(new_value) : return
	get() :
		if body == null : return
		return body.health_component
@export var damage_component : DamageComponent :
	set(new_value) : return
	get() :
		if body == null : return
		return body.damage_component
var current_team : TeamComponent :
	set(new_value) : return
	get() :
		if body == null : return
		return body.team_component
var attacking_snap : bool :
	set(new_value) : return
	get() :
		if !_has_dependencies : return false
		return snappable_component.attacking_snap
var is_recovering : bool :
	set(new_value) : return
	get() :
		if !_has_dependencies : return false
		return snappable_component.is_recovering

## Returns if dependencies are found, cannot be set.
var _has_dependencies : bool :
	set(new_value) : return
	get() : return snappable_component && draggable_component
## Returns if the current piece is being played, cannot be set.
var being_played : bool = false :
	set(new_value) : return
	get() : 
		if current_tile == null : return false 
		return true
## The currently played tile.
var current_tile : Tile :
	set(new_value) :
		if current_tile != null && new_value != null && current_tile != new_value:
			current_tile.disconnected.emit()
		current_tile = new_value
		if current_tile == null : return
		current_tile.connected.emit()
		movement_tiles
		attack_tiles
## The current grid the currently played tile belongs to.
var current_grid : TileGrid :
	set(new_value) : return
	get() :
		if current_tile == null : return 
		return current_tile.grid
## Returns all stored playable movement tiles.
var movement_tiles : Array [Tile] :
	set(new_value) : return
	get() : 
		if movement_reach == null : return []
		if movement_reach.mimic_reach_of != null: return movement_reach.mimic_reach_of.get_playable_tiles()
		return movement_reach.get_playable_tiles()
## Returns all stored playable attacking tiles.
var attack_tiles : Array [Tile] :
	set(new_value) : return
	get() : 
		if attack_reach == null : return []
		if attack_reach.mimic_reach_of != null: return attack_reach.mimic_reach_of.get_playable_tiles()
		return attack_reach.get_playable_tiles()

func get_playable_tiles() :
	attack_tiles
	movement_tiles

func _ready():
	if body == null : body = get_parent_node_3d()
	_get_snappable()
	_get_draggable()
	if !_has_dependencies : return
	loaded_dependencies.emit()
	attacked.connect( func(attacked_by : DamageComponent) : 
		if health_component == null : return
		attacked_by.hit( health_component ))
	play.connect( func (new_tile : Tile) :
		current_tile = new_tile)
	snappable_component.connected.connect(func () : 
		current_tile = snappable_component.snapped_to)
	death.connect( func () : current_tile = null )

## Judges whether or not the provided tile is playable by searching it within the
## currently playable tiles.
func is_tile_playable(current_tile_wannabe : Tile) -> bool:
	if !active || current_grid == null || movement_reach == null : return false
	return movement_reach.is_tile_playable(current_tile_wannabe)

func is_tile_attackable(attacked_tile : Tile) -> bool:
	if !active || current_grid == null || attack_reach == null : return false
	return ( attack_reach.is_tile_playable(attacked_tile) 
	&& attacked_tile.playable_piece
	&& attacked_tile.playable_piece.health_component
	&& attacked_tile.playable_piece.health_component.active
	&& !attacked_tile.playable_piece.health_component.invincible )

func reset_to_playable_position() :
	if !_has_dependencies : return
	snappable_component.recover.emit(current_tile)

## Internal function to retrieve snappable dependency from given body.
func _get_snappable():
	if body == null : return 
	snappable_component = body.read_snappable_component()

## Internal function to retrieve draggable dependency from given body.
func _get_draggable():
	if body == null : return 
	draggable_component = body.read_draggable_component()
