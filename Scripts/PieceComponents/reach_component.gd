class_name ReachComponent extends Node3D

## These are the recommended rounds for a full 360 degrees pattern to be applied around surrounding tiles.
const STANDARD_UNIFORM_PATTERN_ROUNDS : int = 4
const STANDARD_SPECIFIC_PATTERN_ROUNDS : int = 1
const STANDARD_HIGHLIGHT_STRENGTH : float = 0.5
const STANDARD_REACH : int = 1
const STANDARD_MOVEMENT_COLOR : Color = Color.AQUA
const STANDARD_ATTACK_COLOR : Color = Color.DEEP_PINK

## Standard Directions
const HORIZONTAL_LEFT : Vector2i = Vector2i(0, 1)
const HORIZONTAL_RIGHT : Vector2i = Vector2i(0, -1)
const DEPTH_FRONT : Vector2i = Vector2i(1, 0)
const DEPTH_REAR : Vector2i = Vector2i(-1, 0)
const DIAGONAL_FRONTAL_LEFT : Vector2i = Vector2i(1, 1)
const DIAGONAL_FRONTAL_RIGHT : Vector2i = Vector2i(1, -1)
const DIAGONAL_REAR_LEFT : Vector2i = Vector2i(-1, 1)
const DIAGONAL_REAR_RIGHT : Vector2i = Vector2i(-1, -1)

## If not active, no built in components will interact with it, as if it
## didn't exist.
@export var active : bool = true 
## The piece this components belongs to.
@export var playable : PlayableComponent
var body : Piece :
	set(new_value) : return
	get() : 
		if playable == null : return 
		return playable.body
var current_team : TeamComponent :
	set(new_value) : return
	get() :
		if body == null : return
		return body.team_component

@export_category("General Settings")
## If assigned, the playable tiles of this reach component will be copied from the set reach component here.
@export var mimic_reach_of : ReachComponent
## When updated, all reach variables will be set to this standard reach.
@export var standard_reach : int = STANDARD_REACH :
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
## When true, in case the blockage is not ignored, the colliding piece will be returned as playable.
@export var get_colliding_piece : bool = false
## When true, only played tiles (tiles with playables) will be returned as playable tiles.
@export var get_only_played_tiles : bool = false

@export_group("Highlight Settings")
## When on, all playable tiles will be raised up to highlight their availability
## whenever this piece is being dragged.
@export var raise_tiles : bool = true
## When on, all playable tiles will be highlighted with the set highlight color.
@export var highlight_tiles : bool = true
## The weight the highlight color will have on the highlighted tile.
@export var highlight_strength : float = STANDARD_HIGHLIGHT_STRENGTH
@export_enum("Movement", "Attack") var highlight_type : String = "Movement" :
	set(new_value) :
		highlight_type = new_value
		if highlight_type == "Movement" : highlight_color = STANDARD_MOVEMENT_COLOR
		else : highlight_color = STANDARD_ATTACK_COLOR
## The color overlay the tiles will have whenever they are selected.
@export var highlight_color : Color = STANDARD_MOVEMENT_COLOR
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
var horizontal_playables : Array[Tile] :
	set(new_value) : return
	get() : 
		var horizontal_tiles : Array[Tile] = []
		horizontal_tiles.append_array(left_playables)
		horizontal_tiles.append_array(right_playables)
		return horizontal_tiles
var left_playables : Array[Tile] :
	set(new_value) : return
	get() : 
		if follow_left_pattern : return get_tiles_from_pattern(left_pattern, mirror_left_pattern, pattern_rounds)
		return get_tiles(HORIZONTAL_LEFT, horizontal_reach.x, lock_left, ignore_blockage_left)
var right_playables : Array[Tile] :
	set(new_value) : return
	get() : 
		if follow_right_pattern : return get_tiles_from_pattern(right_pattern, mirror_right_pattern, pattern_rounds)
		return get_tiles(HORIZONTAL_RIGHT, horizontal_reach.y, lock_right, ignore_blockage_right)

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
var depth_playables : Array[Tile] :
	set(new_value) : return
	get() : 
		var depth_tiles : Array[Tile] = []
		depth_tiles.append_array(front_playables)
		depth_tiles.append_array(rear_playables)
		return depth_tiles
var front_playables : Array[Tile] :
	set(new_value) : return
	get() : 
		if follow_front_pattern : return get_tiles_from_pattern(front_pattern, mirror_front_pattern, pattern_rounds)
		return get_tiles(DEPTH_FRONT, depth_reach.x, lock_front, ignore_blockage_front)
var rear_playables : Array[Tile] :
	set(new_value) : return
	get() : 
		if follow_rear_pattern : return get_tiles_from_pattern(rear_pattern, mirror_rear_pattern, pattern_rounds)
		return get_tiles(DEPTH_REAR, depth_reach.y, lock_rear, ignore_blockage_rear)

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
## When specific pattern is turned on, turning this feature will let the frontal right reach 
## be used as an specific pattern instead.
@export var follow_frontal_right_pattern : bool = false
## When mirroring frontal left pattern is on, the frontal left pattern will be mirrored doubling the rounds provided.
@export var mirror_frontal_right_pattern : bool = false
## The pattern that will be followed in case specific frontal right pattern is turned on.
@export var frontal_right_pattern : Vector2i = Vector2i.ZERO
var frontal_diagonal_playables : Array[Tile] :
	set(new_value) : return
	get() : 
		var frontal_diagonal_tiles : Array[Tile] = []
		frontal_diagonal_tiles.append_array(frontal_left_playables)
		frontal_diagonal_tiles.append_array(frontal_right_playables)
		return frontal_diagonal_tiles
var frontal_left_playables : Array[Tile] :
	set(new_value) : return
	get() : 
		if follow_frontal_left_pattern : return get_tiles_from_pattern(frontal_left_pattern, mirror_frontal_left_pattern, pattern_rounds)
		return get_tiles(DIAGONAL_FRONTAL_LEFT, frontal_diagonal_reach.x, lock_frontal_left_diagonal, ignore_blockage_frontal_left)
var frontal_right_playables : Array[Tile] :
	set(new_value) : return
	get() : 
		if follow_frontal_right_pattern : return get_tiles_from_pattern(frontal_right_pattern, mirror_frontal_right_pattern, pattern_rounds)
		return get_tiles(DIAGONAL_FRONTAL_RIGHT, frontal_diagonal_reach.y, lock_frontal_right_diagonal, ignore_blockage_frontal_right)

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
var rear_diagonal_playables : Array[Tile] :
	set(new_value) : return
	get() : 
		var rear_diagonal_tiles : Array[Tile] = []
		rear_diagonal_tiles.append_array(rear_left_playables)
		rear_diagonal_tiles.append_array(rear_right_playables)
		return rear_diagonal_tiles
var rear_left_playables : Array[Tile] :
	set(new_value) : return
	get() : 
		if follow_rear_left_pattern : return get_tiles_from_pattern(rear_left_pattern, mirror_rear_left_pattern, pattern_rounds)
		return get_tiles(DIAGONAL_REAR_LEFT, rear_diagonal_reach.x, lock_rear_left_diagonal, ignore_blockage_rear_left)
var rear_right_playables : Array[Tile] :
	set(new_value) : return
	get() : 
		if follow_rear_right_pattern : return get_tiles_from_pattern(rear_right_pattern, mirror_rear_right_pattern, pattern_rounds)
		return get_tiles(DIAGONAL_REAR_RIGHT, rear_diagonal_reach.y, lock_rear_right_diagonal, ignore_blockage_rear_right)

var is_functional : bool :
	set(new_value) : return
	get() : return active && current_grid != null && !uniform_lock
## Returns if the current piece is being played, cannot be set.
var being_played : bool = false :
	set(new_value) : return
	get() : 
		if current_tile == null : return false 
		return true
## The currently played tile.
var current_tile : Tile :
	set(new_value) : return
	get() :
		if playable == null : return
		return playable.current_tile
## The current grid the currently played tile belongs to.
var current_grid : TileGrid :
	set(new_value) : return
	get() :
		if current_tile == null : return 
		return current_tile.grid
## Returns all stored playable tiles.
var playable_tiles : Array [Tile] :
	get() :
		if mimic_reach_of : return mimic_reach_of.playable_tiles
		return playable_tiles

func _ready() -> void:
	if playable == null : return
	playable.loaded_dependencies.connect(func () : 
		playable.draggable_component.started_dragging.connect(func () : 
			get_playable_tiles()
			_highlight_playables(raise_tiles, highlight_tiles))
		playable.snappable_component.grounded.connect(func () : _highlight_playables(false, false))
		playable.snappable_component.connected.connect(func () : _highlight_playables(false, false)))

func _highlight_playables(highlight : bool = true, color : bool = true):
	if body == null || !current_grid : return
	for tile in playable_tiles:
		if tile is Tile: tile.highlight.emit(highlight, color, highlight_color, highlight_strength)

## Judges whether or not the provided tile is playable by searching it within the
## currently playable tiles.
func is_tile_playable(current_tile_wannabe : Tile) -> bool:
	if !active || current_grid == null : return false
	return get_playable_tiles(false).has(current_tile_wannabe)

## Returns the playable tiles from a provided Array[Tile].
## It can be set to ignore any blockage (played tiles), or if returning a found playable tile within the list.
func playable_tiles_from(tile_list : Array[Tile], ignore_block : bool = ignore_blockage, get_played_tile : bool = get_colliding_piece, get_played_tiles : bool = get_only_played_tiles) -> Array[Tile]:
	var playables : Array[Tile] = []
	for tile in tile_list :
		if tile is Tile:
			if ( !get_only_played_tiles && !tile.has_playable ) || ( ( get_only_played_tiles || get_played_tile) && tile.has_playable ) : playables.append(tile)
			if tile.has_playable && !ignore_block : return playables
	return playables

func get_playable_tiles(store_tiles : bool = true) -> Array[Tile]:
	if !is_functional : return []
	
	var playables : Array[Tile] = []

	if follow_uniform_pattern : 
		playables.append_array(playable_tiles_from(get_tiles_from_pattern(), true, false, true))
		if store_tiles : playable_tiles = playables
		return playables
	
	playables.append_array(horizontal_playables)
	playables.append_array(depth_playables)
	playables.append_array(frontal_diagonal_playables)
	playables.append_array(rear_diagonal_playables)
	
	if store_tiles : playable_tiles = playables
	
	return playables

func get_tiles_from_pattern(pattern : Vector2i = uniform_pattern, mirror_pattern : bool = mirror_uniform_pattern, rounds : int = uniform_pattern_rounds) -> Array[Tile] :
	if !is_functional : return []
	return current_grid.get_tiles_following_pattern(current_tile.id, pattern, mirror_pattern, rounds)

func get_tiles(direction : Vector2i, reach : int, is_locked : bool = false, ignore_block : bool = false) -> Array[Tile] :
	if !is_functional || is_locked : return []

	var final_reach : int = reach
	if uniform_movement : final_reach = uniform_reach
	
	var final_tiles : Array[Tile] = current_grid.get_tiles_from(current_tile.id, direction, final_reach)
	
	var playables : Array[Tile] = []
	playables.append_array(playable_tiles_from(final_tiles, ignore_blockage || ignore_block))
	
	return playables
