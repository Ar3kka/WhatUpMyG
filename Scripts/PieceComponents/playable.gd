## Piece component that allows a piece to be playable with its own personalized reach pattern,
## this component is dependant on the piece being draggable, manipulable and snappable.
## For this component to work, the body piece has to have an active draggable component and snappable component.
class_name PlayableComponent extends Node3D

signal play(new_tile : Tile)

## This is the recommended rounds for a full 360 degrees pattern to be applied around surrounding tiles.
const STANDARD_UNIFORM_PATTERN_ROUNDS : int = 4
const STANDARD_SPECIFIC_PATTERN_ROUNDS : int = 1
const STANDARD_HIGHLIGHT_STRENGTH : float = 0.5

## If not active, no built in components will interact with it, as if it
## didn't exist.
@export var active : bool = true :
	get() : 
		if !_has_dependencies : return false
		return active
## The piece this components belongs to.
@export var body : Piece
## The snappable component for dependency.
@export var snappable_component : SnappableComponent
## The draggable component for dependency.
@export var draggable_component : DraggableComponent

@export_category("General Settings")
## When updated, all reach variables will be set to this standard reach.
@export var standard_reach : int = 1 :
	set(new_reach) :
		standard_reach = new_reach
		uniform_reach = standard_reach
		horizontal_reach = Vector2i(standard_reach, standard_reach)
		depth_reach = Vector2i(standard_reach, standard_reach)
		frontal_diagonal_reach = Vector2i(standard_reach, standard_reach)
		rear_diagonal_reach = Vector2i(standard_reach, standard_reach)
## When true, the reach will not be interrupted by obsctruction, 
## allowing the piece to phase through and jump over unplayable tiles
@export var ignore_blockage : bool = false

@export_group("Highlight Settings")
## When on, all playable tiles will be raised up to highlight their availability
## whenever this piece is being dragged.
@export var raise_tiles : bool = true
## When on, all playable tiles will be highlighted with the set highlight color.
@export var highlight_tiles : bool = true
## The weight the highlight color will have on the highlighted tile.
@export var highlight_strength : float = STANDARD_HIGHLIGHT_STRENGTH
## The color overlay the tiles will have whenever they are selected.
@export var highlight_color : Color = Color.DEEP_PINK
@export_group("Pattern Settings")
## When true, all reach will be considered as specific coordinates, 
## ignoring the tiles in its path.
@export var specific_pattern : bool = false
## When true, all patterns will be mirrored doubling the rounds provided
## to ensure a full 360 coverage is done surrounding the playing piece.
@export var mirror_pattern : bool = false
## The standard default pattern rounds for every specific pattern to follow.
@export var pattern_rounds : int = STANDARD_SPECIFIC_PATTERN_ROUNDS :
	set(new_value):
		pattern_rounds = new_value
		uniform_pattern_rounds = new_value

@export_category("Uniform Settings")
## When true, all custom reach will be ignored and only the uniform reach will be taken in account.
@export var uniform_movement : bool = false
## The universal reach, only taken in account if uniform movement is on. 
@export var uniform_reach : int = standard_reach
## When true, locks all movement from all directions.
@export var uniform_lock : bool = false
## When specific pattern is turned on, turning this feature will let the uniform pattern overwrite
## the specific patterns, and only follow the uniform pattern
@export_group("Uniform Pattern Settings")
@export var follow_uniform_pattern : bool = false
## When mirroring uniform pattern is on, the pattern will be mirrored doubling the rounds provided.
@export var mirror_uniform_pattern : bool = false
## Overwritte the rounds 
@export var uniform_pattern_rounds : int = STANDARD_UNIFORM_PATTERN_ROUNDS
## When following uniform pattern, all specific patterns will be replaced by the pattern set here.
@export var uniform_pattern : Vector2i = Vector2i.ZERO

@export_category("Reach Settings")
@export_group("Horizontal Reach")
## This is the horizontal reach for the playable piece: Vector2i(left, right)
@export var horizontal_reach : Vector2i = Vector2i(standard_reach, standard_reach)
## When true, the right reach will not be interrupted by obsctruction, 
## allowing the piece to phase through and jump over unplayable tiles
@export var ignore_blockage_left : bool = false
## When true, the left reach will not be interrupted by obsctruction,
## allowing the piece to phase through and jump over unplayable tiles
@export var ignore_blockage_right : bool = false
## Lock movement to the left
@export var lock_left : bool = false
## Lock movement to the right
@export var lock_right : bool = false
## When specific pattern is turned on, turning this feature will let the reach 
## be used as an specific pattern instead.
@export_subgroup("Horizontal Pattern Settings")
## When specific pattern is turned on, turning this feature will let the left reach 
## be used as an specific pattern instead.
@export var follow_left_pattern : bool = false
## When mirroring left pattern is on, the left pattern will be mirrored doubling the rounds provided.
@export var mirror_left_pattern : bool = false
## The pattern that will be followed in case specific left pattern is turned on.
@export var left_pattern : Vector2i = Vector2i.ZERO
## When specific pattern is turned on, turning this feature will let the right reach 
## be used as an specific pattern instead.
@export var follow_right_pattern : bool = false
## When mirroring right pattern is on, the right pattern will be mirrored doubling the rounds provided.
@export var mirror_right_pattern : bool = false
## The pattern that will be followed in case specific right pattern is turned on.
@export var right_pattern : Vector2i = Vector2i.ZERO
## Returns all horizontal diagonal playable tiles, cannot be set.
var horizontal_playable_tiles : Array[Tile] :
	set(new_value) : return
	get() : return get_horizontal_tiles()

@export_group("Depth Reach")
## This is the frontal and rear reach for the playable piece: Vector2i(front, rear)
@export var depth_reach : Vector2i = Vector2i(standard_reach, standard_reach)
## When true, the frontal reach will not be interrupted by obsctruction, 
## allowing the piece to phase through and jump over unplayable tiles
@export var ignore_blockage_front : bool = false
## When true, the rear reach will not be interrupted by obsctruction, 
## allowing the piece to phase through and jump over unplayable tiles
@export var ignore_blockage_rear : bool = false
## Lock frontal movement
@export var lock_front : bool = false
## Lock rear movement
@export var lock_rear : bool = false
@export_subgroup("Depth Pattern Settings")
## When specific pattern is turned on, turning this feature will let the frontal reach 
## be used as an specific pattern instead.
@export var follow_front_pattern : bool = false
## When mirroring front pattern is on, the front pattern will be mirrored doubling the rounds provided.
@export var mirror_front_pattern : bool = false
## The pattern that will be followed in case specific left pattern is turned on.
@export var front_pattern : Vector2i = Vector2i.ZERO
## When specific pattern is turned on, turning this feature will let the rear reach 
## be used as an specific pattern instead.
@export var follow_rear_pattern : bool = false
## When mirroring rear pattern is on, the rear pattern will be mirrored doubling the rounds provided.
@export var mirror_rear_pattern : bool = false
## The pattern that will be followed in case specific front pattern is turned on.
@export var rear_pattern : Vector2i = Vector2i.ZERO
## Returns all depth playable tiles, cannot be set.
var depth_playable_tiles : Array[Tile] :
	set(new_value) : return
	get() : return get_depth_tiles()

@export_group("Frontal Diagonal Reach")
## This is the frontal diagonal reach for the playable piece: Vector2i(front left, front right)
@export var frontal_diagonal_reach : Vector2i = Vector2i(standard_reach, standard_reach)
## When true, the frontal diagonal left reach will not be interrupted by obsctruction,
## allowing the piece to phase through and jump over unplayable tiles
@export var ignore_blockage_frontal_left : bool = false
## When true, the frontal diagonal right reach will not be interrupted by obsctruction, 
## allowing the piece to phase through and jump over unplayable tiles
@export var ignore_blockage_frontal_right : bool = false
## Lock frontal left diagonal movement
@export var lock_frontal_left_diagonal : bool = false
## Lock frontal rigth diagonal movement
@export var lock_frontal_right_diagonal : bool = false
## Returns all frontal diagonal playable tiles, cannot be set.
@export_subgroup("Frontal Diagonal Pattern Settings")
## When specific pattern is turned on, turning this feature will let the frontal left reach 
## be used as an specific pattern instead.
@export var follow_frontal_left_pattern : bool = false
## When mirroring frontal left pattern is on, the frontat left pattern will be mirrored doubling the rounds provided.
@export var mirror_frontal_left_pattern : bool = false
## The pattern that will be followed in case specific frontal left pattern is turned on.
@export var frontal_left_pattern : Vector2i = Vector2i.ZERO
## When mirroring frontal left pattern is on, the frontal left pattern will be mirrored doubling the rounds provided.
@export var mirror_frontal_right_pattern : bool = false
## When specific pattern is turned on, turning this feature will let the frontal right reach 
## be used as an specific pattern instead.
@export var follow_frontal_right_pattern : bool = false
## When mirroring rear right pattern is on, the rear right pattern will be mirrored doubling the rounds provided.
@export var mirror_rear_right : bool = false
## The pattern that will be followed in case specific frontal right pattern is turned on.
@export var frontal_right_pattern : Vector2i = Vector2i.ZERO
var frontal_diagonal_playable_tiles : Array[Tile] :
	set(new_value) : return
	get() : return get_front_diagonal_tiles()

@export_group("Rear Diagonal Reach")
## This is the rear diagonal reach for the playable piece: Vector2i(rear left, rear right)
@export var rear_diagonal_reach : Vector2i = Vector2i(standard_reach, standard_reach)
## When true, the rear diagonal left reach will not be interrupted by obsctruction,
## allowing the piece to phase through and jump over unplayable tiles
@export var ignore_blockage_rear_left : bool = false
## When true, the rear diagonal right reach will not be interrupted by obsctruction,
## allowing the piece to phase through and jump over unplayable tiles
@export var ignore_blockage_rear_right : bool = false
## Lock rear left diagonal movement
@export var lock_rear_left_diagonal : bool = false
## Lock rear right diagonal movement
@export var lock_rear_right_diagonal : bool = false
## Returns all rear diagonal playable tiles, cannot be set.
@export_subgroup("Rear Diagonal Pattern Settings")
## When specific pattern is turned on, turning this feature will let the rear left reach 
## be used as an specific pattern instead.
@export var follow_rear_left_pattern : bool = false
## When mirroring rear left pattern is on, the rear left pattern will be mirrored doubling the rounds provided.
@export var mirror_rear_left_pattern : bool = false
## The pattern that will be followed in case specific rear left pattern is turned on.
@export var rear_left_pattern : Vector2i = Vector2i.ZERO
## When specific pattern is turned on, turning this feature will let the rear right reach 
## be used as an specific pattern instead.
@export var follow_rear_right_pattern : bool = false
## When mirroring rear right pattern is on, the rear right pattern will be mirrored doubling the rounds provided.
@export var mirror_rear_right_pattern : bool = false
## The pattern that will be followed in case specific rear right pattern is turned on.
@export var rear_right_pattern : Vector2i = Vector2i.ZERO
var rear_diagonal_playable_tiles : Array[Tile] :
	set(new_value) : return
	get() : return get_rear_diagonal_tiles()

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
		current_tile.connected.emit()
		get_playable_tiles()
## The current grid the currently played tile belongs to.
var current_grid : TileGrid :
	set(new_value) : return
	get() :
		if current_tile == null : return 
		return current_tile.grid
## Returns all stored playable tiles.
var playable_tiles : Array [Tile] :
	set(new_tiles) :
		if new_tiles != null && playable_tiles != null && raise_tiles:
			_highlight_playables(false, false)
		playable_tiles = new_tiles

func _highlight_playables(highlight : bool = true, color : bool = true):
	if body == null || !current_grid : return
	for tile in playable_tiles:
		if tile is Tile: tile.highlight.emit(highlight, color, highlight_color, highlight_strength)

func _ready():
	if body == null : body = get_parent_node_3d()
	_get_snappable()
	_get_draggable()
	if !_has_dependencies : return
	play.connect( func (new_tile : Tile) :
		current_tile = new_tile)
	snappable_component.connected.connect(func () : 
		current_tile = snappable_component.snapped_to)
	if !raise_tiles : return 
	draggable_component.started_dragging.connect(func () : 
		get_playable_tiles()
		_highlight_playables(raise_tiles, highlight_tiles))
	snappable_component.grounded.connect(func () : _highlight_playables(false, false))

## Returns all playable tiles following all reach settings.
func get_playable_tiles(store_tiles : bool = true) -> Array[Tile]:
	if current_grid == null || !active || uniform_lock : return []
	
	var playables : Array[Tile] = []

	if follow_uniform_pattern : 
		playables.append_array(get_uniform_pattern_tiles())
		if store_tiles : playable_tiles = playables
		return playables
	
	playables.append_array(horizontal_playable_tiles)
	playables.append_array(depth_playable_tiles)
	playables.append_array(frontal_diagonal_playable_tiles)
	playables.append_array(rear_diagonal_playable_tiles)
	
	if store_tiles : playable_tiles = playables
	
	return playables

## Judges whether or not the provided tile is playable by searching it within the
## currently playable tiles.
func is_tile_playable(current_tile_wannabe : Tile) -> bool:
	if current_grid == null || !active: return false
	return get_playable_tiles(false).has(current_tile_wannabe)

## Returns the playable tiles from a provided Array[Tile].
## It can be set to ignore any blockage (played tiles), or if returning a found playable tile within the list.
func playable_tiles_from(tile_list : Array[Tile], ignore_block : bool = ignore_blockage, get_played_tile : bool = true) -> Array[Tile]:
	var playables : Array[Tile] = []
	for tile in tile_list :
		if tile is Tile:
			if !tile.has_playable || (tile.has_playable && get_played_tile) : playables.append(tile)
			if tile.has_playable && !ignore_block : return playables
	return playables

func get_uniform_pattern_tiles() -> Array[Tile] :
		return current_grid.get_tiles_following_pattern(current_tile.id, uniform_pattern, mirror_uniform_pattern, uniform_pattern_rounds)

## Returns all horizontally playable tiles following their horizontal reach settings.
func get_horizontal_tiles() -> Array[Tile] :
	if uniform_lock || current_grid == null || !active : return []

	var final_reach : Vector2i = horizontal_reach
	if uniform_movement : final_reach = Vector2i(uniform_reach, uniform_reach)
	
	var horizontal_x : Array[Tile] = []
	if !lock_left : 
		if follow_left_pattern : horizontal_x = current_grid.get_tiles_following_pattern(current_tile.id, left_pattern, mirror_left_pattern, pattern_rounds)
		else : horizontal_x = current_grid.get_tiles_from(current_tile.id, Vector2i(0, 1), final_reach.x)
	
	var horizontal_y : Array[Tile] = []
	if !lock_right :
		if follow_right_pattern : horizontal_y = current_grid.get_tiles_following_pattern(current_tile.id, right_pattern, mirror_right_pattern, pattern_rounds)
		else : horizontal_y = current_grid.get_tiles_from(current_tile.id, Vector2i(0, -1), final_reach.y)
	
	var playables : Array[Tile] = []
	playables.append_array(playable_tiles_from(horizontal_x, ignore_blockage || ignore_blockage_left))
	playables.append_array(playable_tiles_from(horizontal_y, ignore_blockage || ignore_blockage_right))
	
	return playables
	
## Returns all depth playable tiles following their depth reach settings.
func get_depth_tiles() -> Array[Tile] :
	if uniform_lock || current_grid == null || !active : return []
	
	var final_reach : Vector2i = depth_reach
	if uniform_movement : final_reach = Vector2i(uniform_reach, uniform_reach)
	
	var depth_x : Array[Tile] = []
	if !lock_front : 
		if follow_front_pattern : depth_x = current_grid.get_tiles_following_pattern(current_tile.id, front_pattern, mirror_front_pattern, pattern_rounds)
		else : depth_x = current_grid.get_tiles_from(current_tile.id, Vector2i(1, 0), final_reach.x)
	var depth_y : Array[Tile] = []
	if !lock_rear : 
		if follow_rear_pattern : depth_y = current_grid.get_tiles_following_pattern(current_tile.id, rear_pattern, mirror_rear_pattern, pattern_rounds)
		else : depth_y = current_grid.get_tiles_from(current_tile.id, Vector2i(-1, 0), final_reach.y)
	
	var playables : Array[Tile] = []
	playables.append_array(playable_tiles_from(depth_x, ignore_blockage || ignore_blockage_front))
	playables.append_array(playable_tiles_from(depth_y, ignore_blockage || ignore_blockage_rear))
	
	return playables
	
## Returns all front diagonal playable tiles following their front diagonal reach settings.
func get_front_diagonal_tiles() -> Array[Tile] :
	if uniform_lock || current_grid == null || !active : return []
	var final_reach : Vector2i = frontal_diagonal_reach
	if uniform_movement : final_reach = Vector2i(uniform_reach, uniform_reach)
	
	var front_diagonal_x : Array[Tile] = []
	if !lock_frontal_left_diagonal : 
		if follow_frontal_left_pattern : front_diagonal_x = current_grid.get_tiles_following_pattern(current_tile.id, frontal_left_pattern, mirror_frontal_left_pattern, pattern_rounds)
		else : front_diagonal_x = current_grid.get_tiles_from(current_tile.id, Vector2i(1, 1), final_reach.x)
	var front_diagonal_y : Array[Tile] = [] 
	if !lock_frontal_right_diagonal : 
		if follow_frontal_right_pattern : front_diagonal_y = current_grid.get_tiles_following_pattern(current_tile.id, frontal_right_pattern, mirror_frontal_right_pattern, pattern_rounds)
		else : front_diagonal_y = current_grid.get_tiles_from(current_tile.id, Vector2i(1, -1), final_reach.y)
	
	var playables : Array[Tile] = []
	playables.append_array(playable_tiles_from(front_diagonal_x, ignore_blockage || ignore_blockage_frontal_left))
	playables.append_array(playable_tiles_from(front_diagonal_y, ignore_blockage || ignore_blockage_frontal_right))
	
	return playables
	
## Returns all rear diagonal playable tiles following their rear diagonal reach settings.
func get_rear_diagonal_tiles() -> Array[Tile] :
	if uniform_lock || current_grid == null || !active : return []

	var final_reach : Vector2i = rear_diagonal_reach
	if uniform_movement : final_reach = Vector2i(uniform_reach, uniform_reach)

	var rear_diagonal_x : Array[Tile] = []
	if !lock_rear_left_diagonal : 
		if follow_rear_left_pattern : rear_diagonal_x = current_grid.get_tiles_following_pattern(current_tile.id, rear_left_pattern, mirror_rear_left_pattern, pattern_rounds)
		else : rear_diagonal_x = current_grid.get_tiles_from(current_tile.id, Vector2i(-1, 1), final_reach.x)
	var rear_diagonal_y : Array[Tile] = []
	if !lock_rear_right_diagonal : 
		if follow_rear_right_pattern : rear_diagonal_y = current_grid.get_tiles_following_pattern(current_tile.id, rear_right_pattern, mirror_rear_right_pattern, pattern_rounds)
		else : rear_diagonal_y = current_grid.get_tiles_from(current_tile.id, Vector2i(-1, -1), final_reach.y)
	
	var playables : Array[Tile] = []
	playables.append_array(playable_tiles_from(rear_diagonal_x, ignore_blockage || ignore_blockage_rear_left))
	playables.append_array(playable_tiles_from(rear_diagonal_y, ignore_blockage || ignore_blockage_rear_right))
	
	return playables

## Internal function to retrieve snappable dependency from given body.
func _get_snappable():
	if body == null : return 
	snappable_component = body.read_snappable_component()

## Internal function to retrieve draggable dependency from given body.
func _get_draggable():
	if body == null : return 
	draggable_component = body.read_draggable_component()
