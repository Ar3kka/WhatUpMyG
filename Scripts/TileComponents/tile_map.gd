class_name TileGrid extends Node3D

signal initial_generation()
signal generated_rows()

const SCENE : PackedScene = preload("res://Scenes/Tiles/tile_grid.tscn")

const STANDARD_SIZE : int = 8
const STANDARD_DIRECTION : Vector2i = Vector2i(-1, -1)
const STANDARD_COLOR_PATTERN : Array[Color] = [Color.WHITE, Color.BLACK]
const STANDARD_RAISE_HEIGHT : float = 0.250

@export var active : bool = true
@export var board : Board
var god : RandomNumberGenerator :
	get() : 
		if board == null : return
		return board.god
## The tiles that this tile grid can generate randomly throughout the map generation accounting by their
## generation chance set in each tile individually.
@export var tile_types : Array[Tile]
## Size for the matrix of tiles, where X represents the horizontal tiles and Y the vertical tiles.
@export var generation_grid_size : Vector2i = Vector2i(STANDARD_SIZE, STANDARD_SIZE)
## When true: the gridmap size will randomize the gridsize within the range provided in the Grid Size
## vector from x to y.
@export var randomize : Vector2i :
	get() : return Vector2i(randomize_depth, randomize_width)
@export var randomize_depth : bool = false
@export var randomize_width : bool = false

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
## Forces the tint of the tiles to be overwritten by the color pattern entered below.
@export var force_pattern : bool = true
## The color pattern that the generation will follow with each printed tile.
## (From 0 onward)
@export var color_pattern : Array[Color] = STANDARD_COLOR_PATTERN
## Switch the color palette every other row in case the color palette matches the grid size
## causing it to merge, turn on or off this variable to change when to skip a color every other row.
@export var color_switch : bool = true

var tiles : Array[Array]
var played_tiles : int = 0
var is_full_of_played_tiles : bool :
	get() :
		if tiles.size() < 1 : return false
		return grid_size_amount == played_tiles
var grid_size : Vector2i :
	get() :
		if tiles.size() < 1 : return Vector2i.ZERO
		return Vector2i( tiles.size(), tiles[0].size() )
var grid_size_amount : int
var is_empty : bool :
	get() : return tiles.size() < 1
var last_row : Array :
	get() : 
		if tiles.size() < 1 : return []
		return tiles.get(tiles.size() - 1)
var last_tile : Tile :
	get() : return last_row[last_row.size() - 1]
var _has_generated : bool = false

func _ready() -> void:
	if !tile_types.size(): _reset_tyle_types()
	
	generated_rows.connect(func () :
		update_grid_tile_amount()
		if !_has_generated : 
			initial_generation.emit()
			_has_generated = true )
	
	#generate_rows()
	#print(get_tiles_from(Vector2i.ZERO, Vector2i(1, 1), 10))
	#print(get_specific_tile_from(Vector2i(1, 1), Vector2i(1, 2)))
	#print(get_tiles_following_pattern(Vector2i(2, 3), Vector2i(2, -1), true))

func update_grid_tile_amount() -> int :
	if tiles.size() < 1 : return 0
	grid_size_amount = tiles.size() * tiles[0].size()
	return grid_size_amount

func reset() :
	if tiles.size() < 1 : return
	for x in range(tiles.size()) :
		for y in range(tiles[x].size()) :
			var tile : Tile = tiles[x][y]
			tile.queue_free()
	tiles = []

func get_random_coordinates(discard_played_tiles : bool = true) -> Vector2i :
	var random_coords : Vector2i
	var iterate : bool = true
	while iterate :
		iterate = false
		random_coords = Vector2i( god.randi_range(0, tiles.size() - 1), god.randi_range(0, tiles[0].size() - 1) )
		if discard_played_tiles && get_tile_at(random_coords).has_playable: iterate = true
		if discard_played_tiles && is_full_of_played_tiles : return Vector2i(-1, -1)
	return random_coords

func instantiate(size : Vector2i = generation_grid_size, random : bool = false, direction : Vector2i = generation_direction) -> TileGrid :
	var new_grid : TileGrid = SCENE.instantiate()
	new_grid.generation_grid_size = size
	#new_grid.randomize = random
	new_grid.generation_direction = direction
	return new_grid

func _reset_tyle_types():
	if !active : return
	tile_types = []
	tile_types.append(Tile.new().instantiate())

## Get tiles in set direction within the grid from an specified coordinate location.
## and returns the specified number of tiles in that direction set by the reach variable.
## the direction vector works as follows: 
## 
## If a direction is not given, a single tile will be returned as part of the array, ignoring the reach given.
func get_tiles_from(origin_coordinates : Vector2i = Vector2i.ZERO, direction : Vector2i = Vector2i(1, 0), reach : int = 1) -> Array[Tile] :
	var result_tiles : Array[Tile]
	if direction == Vector2i.ZERO : 
		tiles.append(get_tile_at(origin_coordinates))
		return result_tiles
	if origin_coordinates.x > generation_grid_size.y : origin_coordinates.x = generation_grid_size.x
	if origin_coordinates.y > generation_grid_size.x : origin_coordinates.y = generation_grid_size.y
	var final_reach = reach
	if final_reach > tiles.size() : final_reach = tiles.size()
	for id in range(final_reach) :
		var final_id = id + 1
		var final_coordinates = origin_coordinates
		if direction.x > 0 : final_coordinates.x += final_id # front
		else : if direction.x < 0 : final_coordinates.x -= final_id # rear
		if direction.y > 0 : final_coordinates.y += final_id # left
		else: if direction.y < 0 : final_coordinates.y -= final_id # right
		var tile : Tile = get_tile_at(final_coordinates)
		if tile != null : result_tiles.append(tile)
	return result_tiles

## Get tiles following an especific direction pattern provided from an origin point,
## rounds of patterns can be set, if mirror is true the rounds will be duplicated and 
## the algorithm will be adapted to scan all possible combinations around the origin tile using the given rounds.
## if pattern is not given, a single tile will be returned from the provided origin coordinates.
func get_tiles_following_pattern(origin_coordinates : Vector2i = Vector2i.ZERO, pattern : Vector2i = Vector2i(1, 0), mirror : bool = true, rounds : int = 4) :
		var result_tiles : Array[Tile]
		if pattern == Vector2i.ZERO :
			result_tiles.append(get_tile_at(origin_coordinates))
			return result_tiles
		var final_pattern : Vector2i = pattern
		if mirror : rounds *= 2
		for round in range(rounds):
			var tile : Tile = get_specific_tile_from(origin_coordinates, final_pattern)
			## Horse algorithm example: 
			# swap, y *= -1 gets negative
			#(2, -1) (2, 1) horse front
			# swap, y *= -1 gets negative
			#(-1, -2) (1, -2) horse right
			# swap, y *= -1 gets positive
			#(-2, 1) (-2, -1) horse rear
			# swap, y *= -1 gets positive
			#(1, 2) (-1, 2) horse left
			# swap, y *= -1 gets negative
			final_pattern = Vector2i(final_pattern.y, final_pattern.x)
			if !mirror || (mirror && round != (rounds / 2) - 1): final_pattern.y *= -1
			result_tiles.append(tile)
		return result_tiles

## Get a single tile following an specific direction starting from the origin coordinates provided where direction is:
## Vector2i(up(1) or down(-1), left (1) or right (-1)).
func get_specific_tile_from(origin_coordinates : Vector2i = Vector2i.ZERO, direction : Vector2i = Vector2i(1, 0)):
	var final_coordinates = Vector2i(origin_coordinates.x + direction.x, origin_coordinates.y + direction.y)
	var result_tile : Tile = get_tile_at(final_coordinates)
	return result_tile

## Get the tile in the coordinates given, returns null if coordinates aren't following
## the current grid size parameters.
func get_tile_at(tile_coordinates : Vector2i = Vector2i.ZERO) -> Tile:
	var supposed_horizontal = tiles.get(tile_coordinates.x)
	if supposed_horizontal == null : return
	return supposed_horizontal.get(tile_coordinates.y)

var current_switch_pattern : bool = color_switch
var color_switch_index : int = 0

func generate_rows(final_size : Vector2i = generation_grid_size, custom_generation_direction : Vector2i = generation_direction, randomize_x : bool = randomize_depth, randomize_y : bool = randomize_width):
	if !active : return
	# Check and initialize the final size of the desired grid
	if randomize_x : final_size.x = god.randi_range(1, generation_grid_size.x)
	if randomize_y : final_size.y = god.randi_range(1, generation_grid_size.y)
	
	if tiles.size() < 1 && color_pattern.size() < 1 : force_pattern = false
	# Check if the new size is an addition, in the case of it being an addition, the grid size will be changed to fit.
	if final_size.x > tiles.size() : generation_grid_size.y += final_size.x
	if tiles && tiles[0] && final_size.y > tiles[0].size() : generation_grid_size.x += final_size.y
	
	## Vertical Tiles
	for z in range(final_size.y):
		# Check if the color patterns are even or odd.
		if color_switch:
			current_switch_pattern = !current_switch_pattern
			if current_switch_pattern && color_switch_index + 1 < color_pattern.size() : color_switch_index += 1
			else: color_switch_index = 0
		# Initialize the new row of vertical tiles.
		var tile_array : Array = [] 
		## Horizontal Tiles
		for x in range(final_size.x):
			# Instantiate the new tile and set its position and id.
			var new_tile = Tile.new().instantiate()
			var last_position : Vector3 = global_position
			if tiles.size() != 0 : last_position = last_row[0].global_position
			new_tile.global_position = Vector3(last_position.x + x * custom_generation_direction.x, last_position.y, last_position.z + 1 * custom_generation_direction.y)
			new_tile.id = Vector2i(tiles.size(), x)
			new_tile.grid = self
			# Check color replacement to follow given pattern
			if force_pattern : new_tile.tint = color_pattern[color_switch_index]
			if color_switch_index + 1 < color_pattern.size() : color_switch_index += 1
			else: color_switch_index = 0
			# Append to array and add child to scene
			tile_array.append(new_tile)
			%Tiles.add_child(new_tile)
		# After finishing the array append it to the list of vertical arrays
		if tile_array.size() != 0: tiles.append(tile_array)
		generated_rows.emit()
