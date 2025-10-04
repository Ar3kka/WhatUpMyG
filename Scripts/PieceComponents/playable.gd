## Piece component that allows a piece to be playable with its own personalized reach pattern,
## this component is dependant on the piece being draggable, manipulable and snappable.
## For this component to work, the body piece has to have an active draggable component and snappable component.
class_name PlayableComponent extends Node3D

signal play(new_tile : Tile)

@export var active : bool = true :
	get() : 
		if !_has_dependencies : return false
		return active
@export var body : Piece
@export var snappable_component : SnappableComponent
@export var draggable_component : DraggableComponent

## When updated, all reach variables will be set to this standard reach.
@export var standard_reach : int = 1 :
	set(new_reach) :
		standard_reach = new_reach
		uniform_reach = standard_reach
		horizontal_reach = Vector2i(standard_reach, standard_reach)
		depth_reach = Vector2i(standard_reach, standard_reach)
		frontal_diagonal_reach = Vector2i(standard_reach, standard_reach)
		rear_diagonal_reach = Vector2i(standard_reach, standard_reach)

## When true, all custom reach will be ignored and only the uniform reach will be taken in account.
@export var uniform_movement : bool = false
## The universal reach, only taken in account if uniform movement is on. 
@export var uniform_reach : int = standard_reach
## When true: locks all movement from all directions.
@export var uniform_lock : bool = false

## When true, all reach will be considered as specific coordinates, instead of uniform reach.
@export var specific_pattern : bool = false

## This is the horizontal reach for the playable piece: Vector2i(left, right)
@export var horizontal_reach : Vector2i = Vector2i(standard_reach, standard_reach)
## Lock movement to the right
@export var lock_right : bool = false
## Lock movement to the left
@export var lock_left : bool = false
var horizontal_playable_tiles : Array[Tile] :
	set(new_value) : return
	get() : return get_horizontal_tiles()

## This is the frontal and rear reach for the playable piece: Vector2i(front, rear)
@export var depth_reach : Vector2i = Vector2i(standard_reach, standard_reach)
## Lock frontal movement
@export var lock_front : bool = false
## Lock rear movement
@export var lock_rear : bool = false
var depth_playable_tiles : Array[Tile] :
	set(new_value) : return
	get() : return get_depth_tiles()

## This is the frontal diagonal reach for the playable piece: Vector2i(front left, front right)
@export var frontal_diagonal_reach : Vector2i = Vector2i(standard_reach, standard_reach)
## Lock frontal left diagonal movement
@export var lock_frontal_left_diagonal : bool = false
## Lock frontal rigth diagonal movement
@export var lock_frontal_right_diagonal : bool = false
var frontal_diagonal_playable_tiles : Array[Tile] :
	set(new_value) : return
	get() : return get_front_diagonal_tiles()

## This is the rear diagonal reach for the playable piece: Vector2i(rear left, rear right)
@export var rear_diagonal_reach : Vector2i = Vector2i(standard_reach, standard_reach)
## Lock rear left diagonal movement
@export var lock_rear_left_diagonal : bool = false
## Lock rear right diagonal movement
@export var lock_rear_right_diagonal : bool = false
var rear_diagonal_playable_tiles : Array[Tile] :
	set(new_value) : return
	get() : return get_rear_diagonal_tiles()

var playable_tiles : Array [Tile] :
	set(new_value) : return
	get() : return get_playable_tiles()

var _has_dependencies : bool :
	set(new_value) : return
	get() : return snappable_component && draggable_component
var being_played : bool = false :
	set(new_value) : return
	get() : 
		if current_tile == null : return false 
		return true
var current_tile : Tile
var current_grid : TileGrid :
	set(new_value) : return
	get() :
		if current_tile == null : return 
		return current_tile.grid

func is_tile_playable(current_tile_wannabe : Tile) -> bool:
	if current_grid == null || !active: return false
	return playable_tiles.has(current_tile_wannabe)

func playable_tiles_from(tile_list : Array[Tile]) -> Array[Tile]:
	var playables : Array[Tile] = [] 
	for tile in tile_list : 
		if !tile.has_playable : playables.append(tile)
	return playables

func get_playable_tiles() -> Array[Tile]:
	if current_grid == null || !active || uniform_lock : return []
	
	var playables : Array[Tile] = []
	
	playables.append_array(horizontal_playable_tiles)
	playables.append_array(depth_playable_tiles)
	playables.append_array(frontal_diagonal_playable_tiles)
	playables.append_array(rear_diagonal_playable_tiles)
	
	return playables

func get_horizontal_tiles() -> Array[Tile] :
	if uniform_lock || current_grid == null || !active : return []

	var final_reach : Vector2i = horizontal_reach
	if uniform_movement : final_reach = Vector2i(uniform_reach, uniform_reach)
	
	var horizontal_x : Array[Tile] = []
	if !lock_left : horizontal_x = current_grid.get_tiles_from(current_tile.id, Vector2i(0, 1), final_reach.x)
	var horizontal_y : Array[Tile] = []
	if !lock_right : horizontal_y = current_grid.get_tiles_from(current_tile.id, Vector2i(0, -1), final_reach.y)
	
	var playables : Array[Tile] = []
	playables.append_array(playable_tiles_from(horizontal_x))
	playables.append_array(playable_tiles_from(horizontal_y))
	
	return playables

func get_depth_tiles() -> Array[Tile] :
	if uniform_lock || current_grid == null || !active : return []
	
	var final_reach : Vector2i = depth_reach
	if uniform_movement : final_reach = Vector2i(uniform_reach, uniform_reach)
	
	var depth_x : Array[Tile] = []
	if !lock_front : depth_x = current_grid.get_tiles_from(current_tile.id, Vector2i(1, 0), final_reach.x)
	var depth_y : Array[Tile] = []
	if !lock_rear : depth_y = current_grid.get_tiles_from(current_tile.id, Vector2i(-1, 0), final_reach.y)
	
	var playables : Array[Tile] = []
	playables.append_array(depth_x)
	playables.append_array(depth_y)
	
	return playables
	
func get_front_diagonal_tiles() -> Array[Tile] :
	if uniform_lock || current_grid == null || !active : return []
	var final_reach : Vector2i = frontal_diagonal_reach
	if uniform_movement : final_reach = Vector2i(uniform_reach, uniform_reach)
	
	var front_diagonal_x : Array[Tile] = []
	if !lock_frontal_left_diagonal : front_diagonal_x = current_grid.get_tiles_from(current_tile.id, Vector2i(1, 1), final_reach.x)
	var front_diagonal_y : Array[Tile] = [] 
	if !lock_frontal_right_diagonal : front_diagonal_y = current_grid.get_tiles_from(current_tile.id, Vector2i(1, -1), final_reach.y)
	
	var playables : Array[Tile] = []
	playables.append_array(front_diagonal_x)
	playables.append_array(front_diagonal_y)
	
	return playables
	
func get_rear_diagonal_tiles() -> Array[Tile] :
	if uniform_lock || current_grid == null || !active : return []

	var final_reach : Vector2i = rear_diagonal_reach
	if uniform_movement : final_reach = Vector2i(uniform_reach, uniform_reach)

	var rear_diagonal_x : Array[Tile] = []
	if !lock_rear_left_diagonal : rear_diagonal_x = current_grid.get_tiles_from(current_tile.id, Vector2i(-1, 1), final_reach.x)
	var rear_diagonal_y : Array[Tile] = []
	if !lock_rear_right_diagonal : rear_diagonal_y = current_grid.get_tiles_from(current_tile.id, Vector2i(-1, -1), final_reach.y)
	
	var playables : Array[Tile] = []
	playables.append_array(rear_diagonal_x)
	playables.append_array(rear_diagonal_y)
	
	return playables

func _get_snappable():
	if body == null : return 
	snappable_component = body.read_snappable_component()
	
func _get_draggable():
	if body == null : return 
	draggable_component = body.read_draggable_component()

func _ready():
	if body == null : body = get_parent_node_3d()
	_get_snappable()
	_get_draggable()
	if !_has_dependencies : return
	play.connect( func (new_tile : Tile) :
		current_tile = new_tile)
	snappable_component.connected.connect(func () : 
		current_tile = snappable_component.snapped_to
		print(get_playable_tiles()) )
