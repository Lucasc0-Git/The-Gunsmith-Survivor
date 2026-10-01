extends Node2D
class_name Map

@onready var map: TileMapLayer = get_node("Map")
@onready var objects: TileMapLayer = get_node("Objects")
@onready var vignette: ColorRect = $ScreenEffects/Vignette

var player: Player
var world_seed: int

signal chunk_generated(new_tree_positions: Array, new_spawner_positions: Array, new_stones_position: Array, new_apple_trees_positions: Array)

@export var world_frequency := 0.05
@export var grass_frequency := 0.4
@export var tree_frequency := 0.85
@export var enemy_spawner_frequency := 1
@export var stone_frequency := 0.9

@export var map_width: int = 100
@export var map_height: int = 100
@export var chunk_size := 16

@export var safe_spawn_area_radius: int = 8

var world_noise := FastNoiseLite.new()
var grass_noise := FastNoiseLite.new()
var tree_noise := FastNoiseLite.new()
var spawner_noise := FastNoiseLite.new()
var stone_noise := FastNoiseLite.new()

var render_distance := 4
var loaded_chunks := {}

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
	
}

func _ready() -> void:
	world_seed = GameManager.current_world_seed
	set_noise_and_seed()
	assert(map.tile_set.tile_size == GridUtils.TILE_SIZE, "GridUtils.TILE_SIZE out of sync with TileSet")
	assert(chunk_size == GridUtils.CHUNK_SIZE, "GridUtils.CHUNK_SIZE out of sync with TileSet")

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

func generate_grid(length: int, seed_f_g: int = 12, chunk_offset: Vector2i = Vector2i(0, 0)) -> void:
	@warning_ignore("integer_division")
	var half_length: int = length / 2
	
	for x in range(-half_length, half_length + (length % 2)):
		for y in range(-half_length, half_length + (length % 2)):
			
			var chunk_coords: Vector2i = Vector2i(x, y) + chunk_offset
			generate_chunk(chunk_coords, seed_f_g)

func generate_chunk(chunk_coords: Vector2i, seed_f_g: int = 12) -> void:
	world_seed = seed_f_g
	set_noise_and_seed()
	
	var half_w := int(float(chunk_size) / 2.0)
	var half_h := int(float(chunk_size) / 2.0)
	
	var offset_x := chunk_coords.x * chunk_size
	var offset_y := chunk_coords.y * chunk_size
	
	var new_trees: Array = []
	var new_spawners: Array = []
	var new_stones: Array = []
	var new_apple_trees: Array = []
	
	for x in range(-half_w, half_w + 1):
		for y in range(-half_h, half_h + 1):
			var world_x := x + offset_x
			var world_y := y + offset_y
			
			var world_value := world_noise.get_noise_2d(world_x, world_y)
			var grass_value := grass_noise.get_noise_2d(world_x, world_y)
			var tree_value := tree_noise.get_noise_2d(world_x, world_y)
			var enemy_value := spawner_noise.get_noise_2d(world_x, world_y)
			var stone_value := stone_noise.get_noise_2d(world_x, world_y)
			var tile_coords : Vector2i
			
			var distance_from_center := Vector2(world_x, world_y).length()
			if distance_from_center < safe_spawn_area_radius:
				tile_coords = be_grass(grass_value)
				map.set_cell(Vector2i(world_x, world_y), 2, tile_coords)
				continue
			
			var local_pos := map.map_to_local(Vector2i(world_x, world_y))
			var global_pos := map.to_global(local_pos)
			if world_value < -0.1: ## Forest
				tile_coords = Vector2i(5, 0) ## Forest podzol
				
				if world_value >= -0.18 and world_value < -0.1:
					if tree_value < -0.2:
						new_apple_trees.append(global_pos)
				else:
					if tree_value < -0.08: ## Tree
						new_trees.append(global_pos)
				
			else: ##Plains
				tile_coords = be_grass(grass_value) ## Grass
				
				if enemy_value < -0.5: ## Spawner
					new_spawners.append(global_pos)
				
			if stone_value > 0.65: ## Stones
				new_stones.append(global_pos)
			
			map.set_cell(Vector2i(world_x, world_y), 2, tile_coords)
	emit_signal("chunk_generated", chunk_coords, new_trees, new_spawners, new_stones, new_apple_trees)

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
			pos_broke.append(tile_pos)
	return pos_broke

func get_mods(chunk_coords: Vector2i) -> Dictionary:
	var mods: Dictionary = {}
	if world_data.has(chunk_coords):
		mods = world_data[chunk_coords].get("chunk_mods", {})
	return mods

func set_chunk_mod(chunk_coords: Vector2i, tile_pos: Vector2i, mod_type: ModType, object_type: String) -> void:
	var chunk_data: Dictionary = world_data.get_or_add(chunk_coords, {})
	var chunk_mods: Dictionary = chunk_data.get_or_add("chunk_mods", {})
	chunk_mods[tile_pos] = {
		"mod_type": mod_type,
		"object_type": object_type
	}

func get_chunk_mod(chunk_coords: Vector2i, tile_pos: Vector2i) -> Dictionary:
	return world_data.get(chunk_coords, {}).get("chunk_mods", {}).get(tile_pos, {})

func clear_chunk_mod(chunk_coords: Vector2i, tile_pos: Vector2i) -> void:
	var chunk_mods: Dictionary = world_data.get(chunk_coords, {}).get("chunk_mods", {})
	chunk_mods.erase(tile_pos)
