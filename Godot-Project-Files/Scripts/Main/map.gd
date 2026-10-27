extends Node2D
class_name Map

@onready var map: TileMapLayer = get_node("Map")
@onready var objects: TileMapLayer = get_node("Objects")
@onready var vignette: ColorRect = $ScreenEffects/Vignette
@onready var main: Main = get_parent()

const WORLD_SEED_MISMATCH_ERR_STRING := "World seed in Map.gd is -1, skipping generation of chunk: "

var player: Player
var world_seed: int = -1

signal chunk_generated(chunk_coords: Vector2i, objects_positions: Dictionary)

@export var world_frequency := 0.05
@export var grass_frequency := 0.4
@export var tree_frequency := 0.85
@export var enemy_spawner_frequency := 1
@export var stone_frequency := 0.9

@export var map_width: int = 100 # outdated
@export var map_height: int = 100 # outdated (map width + height is chosen in main's "generate()" function.
@export var chunk_size := 16

@export var safe_spawn_area_radius: int = 8
@export var render_distance := 4
@export var unload_distance: int = 5

@export_subgroup("Generation Thresholds")
@export_range(-1.0, 1.0) var tree_threshold: float = 0.0 ##Every value that is less than this value means valid position.
@export_range(-1.0, 1.0) var apple_tree_threshold: float = 0.0 ##Every value that is less than this value means valid position.
@export_range(-1.0, 1.0) var forest_threshold: float = 0.0 ##Every value that is less than this value means valid position.
@export_range(-1.0, 1.0) var stone_threshold: float = 0.0 ##Every value that is less than this value means valid position.
@export_range(-1.0, 1.0) var spawner_threshold: float = 0.0 ##Every value that is less than this value means valid position.

var world_noise := FastNoiseLite.new()
var grass_noise := FastNoiseLite.new()
var tree_noise := FastNoiseLite.new()
var spawner_noise := FastNoiseLite.new()
var stone_noise := FastNoiseLite.new()

var loaded_chunks := {}
var _last_player_chunk: Vector2i = Vector2i(0x7FFFFFFF, 0x7FFFFFFF)

var world_mods: Array = [] # [{"pos":..., "type of mod":..., "type of object":..., }, {}]
var world_data: Dictionary[Vector2i, Dictionary] = {} # {Vector2i:{"chunk_mods": {tile_coords:{"type_of_modification":..., "object_type":..., ...}, {}}, {}}

var tiles := { 
	"grass" = Vector2i(1, 0),
	"grass1" = Vector2i(1, 1),
	"grass2" = Vector2i(0, 1),
	"flowers1" = Vector2i(0, 2),
	"flowers2" = Vector2i(1, 2),
	"dark_grass" = Vector2i(1, 3),
	"dark_grass2" = Vector2i (1, 4)
}
var tree_positions := []
var spawner_positions := []
var stone_positions := []

enum ModType {
	DESTROYED,
	GROWN,
	
}

func _ready() -> void:
	world_seed = GameManager.current_world_seed
	set_noise_and_seed()
	assert(map.tile_set.tile_size == GridUtils.TILE_SIZE, "GridUtils.TILE_SIZE out of sync with TileSet")
	assert(chunk_size == GridUtils.CHUNK_SIZE, "GridUtils.CHUNK_SIZE out of sync with TileSet")
	assert(scale.x == GridUtils.MAP_SCALE, "GridUtils.MAP_SCALE out of sync with TileMapLayer")
	
	#print(str(Vector2i(1, 2)), " in tile space is equal to ", str(GridUtils.tile_to_global(Vector2i(1, 2))), " in global space")

func set_noise_and_seed() -> void:
	
	world_noise.seed = world_seed
	world_noise.frequency = world_frequency
	grass_noise.seed = world_seed + 1
	grass_noise.frequency = grass_frequency
	tree_noise.seed = world_seed + 2
	tree_noise.frequency = tree_frequency
	spawner_noise.seed = world_seed + 3
	spawner_noise.frequency = enemy_spawner_frequency
	stone_noise.seed = world_seed + 4
	stone_noise.frequency = stone_frequency

func _process(_delta: float) -> void:
	if not player:
		return
	update_chunks_around_player()

func generate_grid(length: int, chunk_offset: Vector2i = Vector2i(0, 0)) -> void:
	@warning_ignore("integer_division")
	var half_length: int = length / 2
	
	for x in range(-half_length, half_length + (length % 2)):
		for y in range(-half_length, half_length + (length % 2)):
			
			var chunk_coords: Vector2i = Vector2i(x, y) + chunk_offset
			generate_chunk(chunk_coords)

func generate_chunk(chunk_coords: Vector2i) -> void:
	if world_seed == -1:
		push_error(WORLD_SEED_MISMATCH_ERR_STRING, chunk_coords)
		return
	set_noise_and_seed()
	
	var map_tiles: Dictionary = create_map_tiles(chunk_coords)
	
	for tile: Vector2i in map_tiles:
		map.set_cell(tile, 2, map_tiles[tile])
	
	chunk_generated.emit(chunk_coords, create_object_positions(chunk_coords))

func create_map_tiles(chunk_coords: Vector2i) -> Dictionary:
	if world_seed == -1:
		push_error(WORLD_SEED_MISMATCH_ERR_STRING, chunk_coords)
		return {}
	set_noise_and_seed()
	
	var origin := chunk_coords * chunk_size
	
	var d: Dictionary = {}
	
	for x in range(chunk_size):
		for y in range(chunk_size):
			
			var world_x := origin.x + x
			var world_y := origin.y + y
			
			var world_value := world_noise.get_noise_2d(world_x, world_y)
			var grass_value := grass_noise.get_noise_2d(world_x, world_y)
			var tile_coords : Vector2i
			
			
			var distance_from_center := Vector2(world_x, world_y).length()
			if distance_from_center < safe_spawn_area_radius:
				tile_coords = be_grass(grass_value)
				d[Vector2i(world_x, world_y)] = tile_coords
				continue
			
			if world_value < forest_threshold: ## Forest
				tile_coords = Vector2i(5, 0) # Forest podzol
			else:
				tile_coords = be_grass(grass_value)
			
			d[Vector2i(world_x, world_y)] = tile_coords
	
	
	return d # will be {Vector2i: Vector2i, Vector2i: Vector2i}

func create_object_positions(chunk_coords: Vector2i) -> Dictionary:
	if world_seed == -1:
		push_error(WORLD_SEED_MISMATCH_ERR_STRING, chunk_coords)
		return {}
	set_noise_and_seed()
	
	var origin := chunk_coords * chunk_size
	
	var new_trees: Array = []
	var new_spawners: Array = []
	var new_stones: Array = []
	var new_apple_trees: Array = []
	
	for x in range(chunk_size):
		for y in range(chunk_size):
			
			var world_x := origin.x + x
			var world_y := origin.y + y
			
			var world_value := world_noise.get_noise_2d(world_x, world_y)
			var tree_value := tree_noise.get_noise_2d(world_x, world_y)
			var enemy_value := spawner_noise.get_noise_2d(world_x, world_y)
			var stone_value := stone_noise.get_noise_2d(world_x, world_y)
			
			var distance_from_center := Vector2(world_x, world_y).length()
			if distance_from_center < safe_spawn_area_radius:
				continue
			
			var local_pos := map.map_to_local(Vector2i(world_x, world_y))
			var global_pos := map.to_global(local_pos)
			
			if world_value < forest_threshold: ## Forest
				
				if world_value >= (forest_threshold - 0.08) and world_value < forest_threshold:
					if tree_value < apple_tree_threshold:
						new_apple_trees.append(global_pos)
				else:
					if tree_value < tree_threshold: ## Tree
						new_trees.append(global_pos)
				
			else: ##Plains
				
				if enemy_value < spawner_threshold: ## Spawner
					new_spawners.append(global_pos)
				
			if stone_value < stone_threshold: ## Stones
				new_stones.append(global_pos)
	
	var d: Dictionary = {}
	d["trees"] = new_trees
	d["stones"] = new_stones
	d["spawners"] = new_spawners
	d["apple_trees"] = new_apple_trees
	
	return d # will be {"stones":[], "trees":[], ...}

func be_grass(grass_value: float) -> Vector2i:
	if grass_value < -0.05:
		return tiles.grass
	elif grass_value < 0.05:
		return tiles.grass1
	elif grass_value < 0.25:
		return tiles.grass2
	elif grass_value < 0.45:
		return tiles.flowers1
	elif grass_value < 0.65:
		return tiles.flowers2
	elif grass_value < 0.85:
		return tiles.dark_grass
	elif grass_value < 1.0:
		return tiles.dark_grass2
	else: return tiles.grass

func get_spawn_position() -> Vector2:
	var spawn_tile := find_spawn_tile()
	var spawn_pos := map.map_to_local(spawn_tile)
	return spawn_pos

func find_spawn_tile() -> Vector2i:
	var search_radius := 10
	for r in range (search_radius):
		for x in range(-r, r+1):
			for y in range(-r, r+1):
				var tile := Vector2i(x, y)
				var source_id := map.get_cell_source_id(tile)
				
				if source_id != -1:
					var atlas := map.get_cell_atlas_coords(tile)
					if atlas != Vector2i(0, 0): #Change this to atlas coords of nonspawnable blocks
						return tile
	return Vector2i(0, 0)

func set_vignette_strength(target: float, duration: float) -> void:
	var tween := create_tween()
	tween.tween_method(
		func(val: float) -> void: vignette.material.set_shader_parameter("edge_end", val),
		vignette.material.get_shader_parameter("edge_end"),
		target,
		duration
	)

func get_broke_positions(chunk_coords: Vector2i) -> Array:
	var pos_broke: Array = []
	var mods: Dictionary = get_mods(chunk_coords)
	for tile_pos: Vector2i in mods:
		if mods[tile_pos].get("mod_type") == ModType.DESTROYED:
			var global_pos: Vector2 = map.to_global(GridUtils.tile_to_local(tile_pos))
			pos_broke.append(global_pos)
	return pos_broke

func get_mods(chunk_coords: Vector2i) -> Dictionary:
	var mods: Dictionary = {}
	if world_data.has(chunk_coords):
		mods = world_data[chunk_coords].get("chunk_mods", {})
	return mods

func set_tile_mod(chunk_coords: Vector2i, tile_pos: Vector2i, mod_type: ModType, object_type: String, additional_args: Dictionary = {}) -> void:
	var chunk_data: Dictionary = world_data.get_or_add(chunk_coords, {})
	var chunk_mods: Dictionary = chunk_data.get_or_add("chunk_mods", {})
	chunk_mods[tile_pos] = {
		"mod_type": mod_type,
		"object_type": object_type,
		"additional_args": additional_args
	}

func get_tile_mod(chunk_coords: Vector2i, tile_pos: Vector2i) -> Dictionary:
	return world_data.get(chunk_coords, {}).get("chunk_mods", {}).get(tile_pos, {})

func clear_chunk_mod(chunk_coords: Vector2i, tile_pos: Vector2i) -> void:
	var chunk_mods: Dictionary = world_data.get(chunk_coords, {}).get("chunk_mods", {})
	chunk_mods.erase(tile_pos)

# ========================= CHUNK LOADING & UNLOADING =========================

func load_chunk(chunk_coords: Vector2i) -> void:
	if chunk_coords in loaded_chunks: return
	loaded_chunks[chunk_coords] = true
	
	var map_tiles: Dictionary = create_map_tiles(chunk_coords)
	for tile: Vector2i in map_tiles:
		map.set_cell(tile, 2, map_tiles[tile])
	
	var object_positions: Dictionary = create_object_positions(chunk_coords)
	
	chunk_generated.emit(chunk_coords, object_positions)

func unload_chunk(chunk_coords: Vector2i) -> void:
	if not chunk_coords in loaded_chunks: return
	loaded_chunks.erase(chunk_coords)
	
	var origin := chunk_coords * chunk_size
	for x in range(chunk_size):
		for y in range(chunk_size):
			map.set_cell(origin + Vector2i(x, y), -1)
	
	if not main.chunk_objects.has(chunk_coords):
		return
	
	var nodes: Array = main.chunk_objects[chunk_coords].duplicate()
	print(self)
	print(nodes)
	for node: Node2D in nodes:
		if is_instance_valid(node):
			node.queue_free()
	main.chunk_objects.erase(chunk_coords)

func update_chunks_around_player() -> void:
	var player_chunk: Vector2i = GridUtils.get_chunk_coords(player.global_position)
	if player_chunk == _last_player_chunk:
		return
	
	_last_player_chunk = player_chunk
	
	var needed: Dictionary = {}
	
	for x in range(player_chunk.x - render_distance, player_chunk.x + render_distance + 1):
		for y in range(player_chunk.y - render_distance, player_chunk.y + render_distance + 1):
			needed[Vector2i(x, y)] = true
	
	for coords: Vector2i in needed:
		if not loaded_chunks.has(coords):
			load_chunk(coords)
	
	var to_unload: Array[Vector2i] = []
	for coords: Vector2i in loaded_chunks:
		var dx := absi(coords.x - player_chunk.x)
		var dy := absi(coords.y - player_chunk.y)
		if maxi(dx, dy) > unload_distance:
			to_unload.append(coords)
	
	for coords in to_unload:
		unload_chunk(coords)
