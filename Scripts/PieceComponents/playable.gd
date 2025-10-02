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

@export var standard_reach : int = 1 :
	set(new_reach) :
		standard_reach = new_reach
		uniform_reach = standard_reach
		horizontal_reach = Vector2i(standard_reach, standard_reach)
		depth_reach = Vector2i(standard_reach, standard_reach)
		frontal_diagonal_reach = Vector2i(standard_reach, standard_reach)
		rear_diagonal_reach = Vector2i(standard_reach, standard_reach)

@export var uniform_reach : int = standard_reach
@export var uniform_lock : bool = false

@export var specific_pattern : bool = true

@export var horizontal_reach : Vector2i = Vector2i(standard_reach, standard_reach)
@export var lock_horizontal : bool = false

@export var depth_reach : Vector2i = Vector2i(standard_reach, standard_reach)
@export var lock_depth : bool = false

@export var frontal_diagonal_reach : Vector2i = Vector2i(standard_reach, standard_reach)
@export var lock_frontal_diagonal : bool = false

@export var rear_diagonal_reach : Vector2i = Vector2i(standard_reach, standard_reach)
@export var lock_rear_diagonal : bool = false

var _has_dependencies : bool :
	set(new_value) : return
	get() : return snappable_component && draggable_component
var being_played : bool = false :
	set(new_value) : return
	get() : 
		if current_tile == null : return false 
		return true
var current_tile : Tile

func is_tile_playable(current_tile_wannabe : Tile) -> bool:
	var final_veredict : bool = false
	return final_veredict

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
	snappable_component.snap.connect(func () : 
		current_tile = snappable_component.snapped_to )#print("it is I, now I act as the playable node and I shall return the playable piece to the tile it was snapped into, as well as prevent the tile from housing any other occupiers other than the one it already has"))
