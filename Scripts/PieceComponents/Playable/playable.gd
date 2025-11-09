## Piece component that allows a piece to be playable with its own personalized reach pattern,
## this component is dependant on the piece being draggable, manipulable and snappable.
## For this component to work, the body piece has to have an active draggable component and snappable component.
class_name PlayableComponent extends Node3D

const STANDARD_LAST_MOVEMENT_COLOR : Color = Color.GOLD

signal loaded_dependencies()

signal played()
signal unplayed()

signal first_move()

signal attacked(attacked_by : DamageComponent)
signal kill(killed_piece : PlayableComponent)
signal death(by_take : bool)

## If not active, no built in components will interact with it, as if it
## didn't exist.
@export var active : bool = true :
	get() : 
		if !_has_dependencies || is_deceased : return false
		return active
## The piece this components belongs to.
@export var body : Piece
@export var coordinates : Vector2i :
	set(new_coords) : set_coordinates(new_coords, true, true)
	get() :
		if current_tile == null : return Vector2i.ZERO
		return current_tile.id
var highlight_latest_tile : bool = true
@export var last_movement_color : Color = STANDARD_LAST_MOVEMENT_COLOR
var _generation_move : bool = true
var _first_move : bool = true
var mother : PieceGenerator :
	get() :
		if body == null : return
		return body.mother
var asus : Board :
	get() :
		if mother == null : return
		return mother.board 
## The currently played tile.
var current_tile : Tile :
	set(new_tile) :
		if current_tile != null && new_tile != null && current_tile != new_tile:
			current_tile.disconnect_playable()
			if _first_move : first_move.emit()
		
		current_tile = new_tile
		if current_tile == null : return
		if !_generation_move :  _first_move = false
		_generation_move = false
		current_tile.connect_to(self)
		movement_tiles
		attack_tiles
## The current grid the currently played tile belongs to.
var current_grid : TileGrid :
	get() :
		if current_tile : return current_tile.grid
		if asus : return asus.grid
		return
## Returns all stored playable movement tiles.
var movement_tiles : Array [Tile] :
	get() : 
		if movement_reach == null : return []
		if movement_reach.mimic_reach_of != null: return movement_reach.mimic_reach_of.get_playable_tiles()
		return movement_reach.get_playable_tiles()
## Returns all stored playable attacking tiles.
var attack_tiles : Array [Tile] :
	get() : 
		if attack_reach == null : return []
		if attack_reach.mimic_reach_of != null: return attack_reach.mimic_reach_of.get_playable_tiles()
		return attack_reach.get_playable_tiles()
var is_deceased : bool :
	get() :
		if !_has_dependencies || body.health_component == null : return false
		return !body.health_component.alive
var current_team : TeamComponent :
	get() :
		if body == null : return
		return body.team_component
var attacking_snap : bool :
	get() :
		if !_has_dependencies : return false
		return snappable_component.attacking_snap
var is_recovering : bool :
	get() :
		if !_has_dependencies : return false
		return snappable_component.is_recovering
var keyboard_recovery : bool :
	get() :
		if !_has_dependencies : return false
		return snappable_component.keyboard_recovery
var friendly_fire : bool = false
var invert_attack_axis : bool = false :
	set(new_value) :
		if attack_reach == null || !attack_reach.active : return
		attack_reach.invert_all_axis()
	get() :
		if attack_reach == null || !attack_reach.active : return false
		return attack_reach.are_axis_inverted
var invert_movement_axis : bool = false :
	set(new_value) :
		if movement_reach == null || !movement_reach.active : return
		movement_reach.invert_all_axis()
	get() :
		if movement_reach == null || !movement_reach.active : return false
		return movement_reach.are_axis_inverted

## Returns if dependencies are found, cannot be set.
var _has_dependencies : bool :
	get() : return snappable_component && draggable_component
## Returns if the current piece is being played, cannot be set.
var being_played : bool = false :
	get() : 
		if current_tile == null : return false 
		return true
var actions : Array[Action] = []
var last_movement : Action :
	get() :
		if actions.is_empty() : return
		var index = actions.size()
		for action in actions :
			index -= 1
			if actions[index].has_moved : return actions[index]
		return

@export_group("Dependencies")
## The snappable component for dependency.
@export var snappable_component : SnappableComponent
## The draggable component for dependency.
@export var draggable_component : DraggableComponent
@export var selectable_component : SelectableComponent
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
@export var movement_reach : ReachComponent
@export var attack_reach : ReachComponent
@export var state_machine : StateMachine
var last_movement_id : int = 0
# MOVEMENT ID:
# 0 or other : STATIC
# 1 : LEFT
# 2 : RIGHT
# 3 : FRONT
# 4 : REAR
# 5 : TOP LEFT
# 6 : TOP RIGHT
# 7 : REAR LEFT
# 8 : REAR RIGHT

func get_front_left_tile() -> Tile :
	if !_has_dependencies : return
	var final_coordiantes := Vector2i(coordinates.x + 1, coordinates.y + 1)
	if current_tile != snappable_component.snapped_to && snappable_component.snapped_to != null : 
		final_coordiantes = Vector2i(snappable_component.snapped_to.id.x + 1, snappable_component.snapped_to.id.y + 1)
	return current_grid.get_tile_at(final_coordiantes)

func get_front_right_tile() -> Tile :
	if !_has_dependencies : return
	var final_coordiantes := Vector2i(coordinates.x + 1 , coordinates.y - 1)
	if current_tile != snappable_component.snapped_to && snappable_component.snapped_to != null : 
		final_coordiantes = Vector2i(snappable_component.snapped_to.id.x + 1, snappable_component.snapped_to.id.y - 1)
	return current_grid.get_tile_at(final_coordiantes)

func get_rear_left_tile() -> Tile :
	if !_has_dependencies : return
	var final_coordiantes := Vector2i(coordinates.x - 1 , coordinates.y + 1)
	if current_tile != snappable_component.snapped_to && snappable_component.snapped_to != null : 
		final_coordiantes = Vector2i(snappable_component.snapped_to.id.x - 1, snappable_component.snapped_to.id.y + 1)
	return current_grid.get_tile_at(final_coordiantes)

func get_rear_right_tile() -> Tile :
	if !_has_dependencies : return
	var final_coordiantes := Vector2i(coordinates.x - 1 , coordinates.y - 1)
	if current_tile != snappable_component.snapped_to && snappable_component.snapped_to != null : 
		final_coordiantes = Vector2i(snappable_component.snapped_to.id.x - 1, snappable_component.snapped_to.id.y - 1)
	return current_grid.get_tile_at(final_coordiantes)

func get_front_tile() -> Tile :
	if !_has_dependencies : return
	var final_coordiantes := Vector2i(coordinates.x + 1, coordinates.y)
	if current_tile != snappable_component.snapped_to && snappable_component.snapped_to != null : 
		final_coordiantes = Vector2i(snappable_component.snapped_to.id.x + 1, snappable_component.snapped_to.id.y)
	return current_grid.get_tile_at(final_coordiantes)

func get_rear_tile() -> Tile :
	if !_has_dependencies : return
	var final_coordiantes := Vector2i(coordinates.x - 1, coordinates.y)
	if current_tile != snappable_component.snapped_to && snappable_component.snapped_to != null : 
		final_coordiantes = Vector2i(snappable_component.snapped_to.id.x - 1, snappable_component.snapped_to.id.y)
	return current_grid.get_tile_at(final_coordiantes)

func get_left_tile() -> Tile :
	if !_has_dependencies : return
	var final_coordiantes := Vector2i(coordinates.x, coordinates.y + 1)
	if current_tile != snappable_component.snapped_to && snappable_component.snapped_to != null : 
		final_coordiantes = Vector2i(snappable_component.snapped_to.id.x, snappable_component.snapped_to.id.y + 1)
	return current_grid.get_tile_at(final_coordiantes)

func get_right_tile() -> Tile :
	if !_has_dependencies : return
	var final_coordiantes := Vector2i(coordinates.x, coordinates.y - 1)
	if current_tile != snappable_component.snapped_to && snappable_component.snapped_to != null : 
		final_coordiantes = Vector2i(snappable_component.snapped_to.id.x, snappable_component.snapped_to.id.y - 1)
	return current_grid.get_tile_at(final_coordiantes)

func is_tile_unavailable(tile : Tile, ignore_playable : bool = false, ignore_attackable : bool = false) -> bool :
	if tile == null : return true
	if !ignore_playable && tile.has_playable && tile.playable_piece != self && ( !ignore_attackable && !is_tile_attackable(tile) ) : return true
	if !ignore_attackable && !is_tile_attackable(tile) && ignore_playable : return true
	return false


func move_to_left(connect : bool = false, set_position : bool = false, ignore_playable : bool = false, ignore_attackable : bool = false):
	var tile : Tile = get_left_tile()
	if is_tile_unavailable(tile, ignore_playable, ignore_attackable) : return
	last_movement_id = 1
	set_coordinates(tile.id, connect, set_position)
	
func move_to_right(connect : bool = false, set_position : bool = false, ignore_playable : bool = false, ignore_attackable : bool = false):
	var tile : Tile = get_right_tile()
	if is_tile_unavailable(tile, ignore_playable, ignore_attackable) : return
	last_movement_id = 2
	set_coordinates(tile.id, connect, set_position)

func move_to_front(connect : bool = false, set_position : bool = false, ignore_playable : bool = false, ignore_attackable : bool = false):
	var tile : Tile = get_front_tile()
	if is_tile_unavailable(tile, ignore_playable, ignore_attackable) : return
	last_movement_id = 3
	set_coordinates(tile.id, connect, set_position)

func move_to_rear(connect : bool = false, set_position : bool = false, ignore_playable : bool = false, ignore_attackable : bool = false):
	var tile : Tile = get_rear_tile()
	if is_tile_unavailable(tile, ignore_playable, ignore_attackable) : return
	last_movement_id = 4
	set_coordinates(tile.id, connect, set_position)

func move_to_front_left(connect : bool = false, set_position : bool = false, ignore_playable : bool = false, ignore_attackable : bool = false):
	var tile : Tile = get_front_left_tile()
	if is_tile_unavailable(tile, ignore_playable, ignore_attackable) : return
	last_movement_id = 5
	set_coordinates(tile.id, connect, set_position)

func move_to_front_right(connect : bool = false, set_position : bool = false, ignore_playable : bool = false, ignore_attackable : bool = false):
	var tile : Tile = get_front_right_tile()
	if is_tile_unavailable(tile, ignore_playable, ignore_attackable) : return
	last_movement_id = 6
	set_coordinates(tile.id, connect, set_position)

func move_to_rear_left(connect : bool = false, set_position : bool = false, ignore_playable : bool = false, ignore_attackable : bool = false):
	var tile : Tile = get_rear_left_tile()
	if is_tile_unavailable(tile, ignore_playable, ignore_attackable) : return
	last_movement_id = 7
	set_coordinates(tile.id, connect, set_position)

func move_to_rear_right(connect : bool = false, set_position : bool = false, ignore_playable : bool = false, ignore_attackable : bool = false):
	var tile : Tile = get_rear_right_tile()
	if is_tile_unavailable(tile, ignore_playable, ignore_attackable) : return
	last_movement_id = 8
	set_coordinates(tile.id, connect, set_position)

func set_coordinates(new_coords : Vector2i, connect : bool = false, set_position : bool = false) :
	if !active || current_grid == null : return
	if current_tile :
		if connect : current_tile.disconnect_playable() ; unplay()
		current_tile.unocuppy()
	var grid_size : Vector2i = current_grid.grid_size
	var target_tile : Tile
	target_tile = current_grid.get_tile_at(new_coords)
	target_tile.occupy(body)
	
	if connect : play(target_tile)
	else : if snappable_component : 
		snappable_component.keyboard_recovery = true
		snappable_component.recover.emit(target_tile)
		if is_tile_attackable(target_tile) : attacking_snap = true
	
	if !set_position : return
	if target_tile : body.global_position = target_tile.global_position ; return
	if mother : body.global_position = mother.spawn_point ; return
	if current_grid : body.global_position = current_grid.center_point ; return
	body.global_position = Vector3.ZERO

func stop_highlight() :
	if attack_reach : attack_reach._highlight_playables(false, false)
	if movement_reach : movement_reach._highlight_playables(false, false)

func get_playable_tiles() :
	attack_tiles
	movement_tiles

func play(new_tile : Tile, highlight : bool = true) :
	if highlight : unhighlight_played_tiles()
	current_tile = new_tile
	if highlight : highlight_last_played_tile()
	played.emit()

func unplay() :
	current_tile = null
	unplayed.emit()

func highlight_last_played_tile() :
	if last_movement == null || !highlight_latest_tile : return 
	last_movement.moved_from.color_highlight(last_movement_color, false)

func unhighlight_played_tiles() :
	if actions.is_empty() == null || !highlight_latest_tile : return
	for action in actions : 
		if action.has_moved : action.moved_from.unhighlight()

func _ready():
	if body == null : body = get_parent_node_3d()
	_get_snappable()
	_get_draggable()
	_get_selectable()
	if !_has_dependencies : return
	loaded_dependencies.emit()
	
	body.found_health.connect(func () : 
		body.health_component.death.connect(func () : death.emit() ))
	
	snappable_component.grounded.connect(func () : highlight_last_played_tile())
	
	snappable_component.connected.connect(func () : 
		play(snappable_component.snapped_to) )
	
	selectable_component.just_selected.connect(func() : highlight_last_played_tile())
	
	selectable_component.just_deselected.connect((func() : unhighlight_played_tiles()))
	
	attacked.connect( func(attacked_by : DamageComponent) : 
		if health_component == null : return
		attacked_by.hit( health_component )
		if snappable_component && health_component.alive : snappable_component.auto_recover.emit(true) )
	
	death.connect(func (by_take : bool = true) :
		unplay()
		if snappable_component : snappable_component.stop_snapping()
		if draggable_component : draggable_component.stop_dragging()
		if !by_take : current_tile.disconnect_playable() )
	
	kill.connect(func (killed_piece : PlayableComponent) :
		stop_highlight()
		snappable_component.stop_snapping()
		snappable_component.snap_to(killed_piece.current_tile)
		current_tile.unocuppy()
		play(killed_piece.current_tile)
		current_tile.occupy(body)
		get_playable_tiles() )

## Judges whether or not the provided tile is playable by searching it within the
## currently playable tiles.
func is_tile_playable(current_tile_wannabe : Tile) -> bool:
	if !active || current_grid == null || movement_reach == null : return false
	return movement_reach.is_tile_playable(current_tile_wannabe)

func is_tile_attackable(attacked_tile : Tile) -> bool:
	if !active || current_grid == null || attack_reach == null : return false
	return ( attack_reach.is_tile_playable(attacked_tile) 
	&& attacked_tile.playable_piece
	&& ( attacked_tile.playable_piece.current_team.id != current_team.id || friendly_fire )
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

func _get_selectable():
	if body == null : return 
	selectable_component = body.read_selectable_component()
