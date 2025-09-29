class_name TileGrid extends Node3D

const STANDARD_SIZE : int = 8
const STANDARD_DIRECTION : Vector2i = Vector2i(-1, -1)

@export var active : bool = true
## The tiles that this tile grid can generate randomly throughout the map generation accounting by their
## generation chance set in each tile individually.
@export var tile_types : Array[Tile]
## Size for the matrix of tiles, where X represents the horizontal tiles and Y the vertical tiles.
@export var grid_size : Vector2i = Vector2i(STANDARD_SIZE, STANDARD_SIZE)
## When true: the gridmap size will randomize the gridsize within the range provided in the Grid Size
## vector from x to y.
@export var randomize : bool = false
## Direction for generation where X represents the horizontal direction and Y the vertical direction.
## If left on 0 it will set it to the standard direction (-1, -1)
@export var generation_direction : Vector2i = STANDARD_DIRECTION :
	set(new_direction):
		if new_direction.x == 0 : generation_direction.x = STANDARD_DIRECTION.x
		if new_direction.y == 0 : generation_direction.y = STANDARD_DIRECTION.y
		if new_direction.x > 1 : generation_direction.x = 1
		if new_direction.y > 1 : generation_direction.y = 1
		if new_direction.x < -1 : generation_direction.x = -1
		if new_direction.y < -1 : generation_direction.y = -1
var tiles : Array[Array] 

func _ready() -> void:
	if !tile_types.size(): _reset_tyle_types()
	generate_tiles()

func _reset_tyle_types():
	if !active : return
	tile_types = []
	tile_types.append(Tile.new())

func get_tile_at(horizontal_coordinate : int, vertical_coordinate : int) -> Tile:
	return tiles.get(horizontal_coordinate).get(vertical_coordinate)
	
func generate_tiles():
	if !active : return
	var black : bool = false
	var final_size : Vector2i = grid_size
	if randomize : final_size = Vector2i(randi_range(grid_size.x, grid_size.y), randi_range(grid_size.x, grid_size.y)) 
	for z in range(final_size.y):
		var tile_array : Array = []
		if final_size.y % 2 == 0: black = !black
		for x in range(final_size.x):
			var new_tile = Tile.new().instantiate()
			new_tile.global_position = Vector3(global_position.x + x * generation_direction.x, global_position.y, global_position.z + z * generation_direction.y)
			new_tile.id = Vector2i(z, x)
			if black : new_tile.tint = Color.BLACK
			tile_array.append(new_tile)
			%Tiles.add_child(new_tile)
			black = !black
		if tile_array.size() != 0: tiles.append(tile_array)
