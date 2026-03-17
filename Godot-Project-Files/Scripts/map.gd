extends Node2D
class_name Map

@onready var map: TileMapLayer = get_node("Map")
@onready var objects: TileMapLayer = get_node("Objects")
@onready var vignette: ColorRect = $ScreenEffects/Vignette

var player: Player
var world_seed: int

signal region_generated(new_tree_positions: Array, new_spawner_positions: Array)

@export var world_frequency := 0.05
@export var grass_frequency := 0.4
@export var tree_frequency := 0.85
@export var enemy_spawner_frequency := 1
@export var map_width: int = 100
@export var map_height: int = 100

@warning_ignore("integer_division")
var half_w := map_width / 2
@warning_ignore("integer_division")
var half_h := map_height /2

var world_noise := FastNoiseLite.new()
var grass_noise := FastNoiseLite.new()
var tree_noise := FastNoiseLite.new()
var spawner_noise := FastNoiseLite.new()

var chunk_size := 32
var render_distance := 4
var loaded_chunks := {}
var world_mods := {}
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

func _ready() -> void:
	world_seed = GameManager.current_world_seed
	world_noise.seed = world_seed
	world_noise.frequency = world_frequency
	grass_noise.seed = world_seed + 1
	grass_noise.frequency = grass_frequency
	tree_noise.seed = world_seed + 2
	tree_noise.frequency = tree_frequency
	spawner_noise.seed = world_seed + 3
	spawner_noise.frequency = enemy_spawner_frequency

func generate_region(region_pos: Vector2i) -> void:
	var offset_x := region_pos.x * map_width
	var offset_y := region_pos.y * map_height
	
	var new_trees: Array = []
	var new_spawners: Array = []
	
	for x in range(-half_w, half_w + 1):
		for y in range(-half_h, half_h + 1):
			var world_x := x + offset_x
			var world_y := y + offset_y
			
			var world_value := world_noise.get_noise_2d(x, y)
			var grass_value := grass_noise.get_noise_2d(x, y)
			var tree_value := tree_noise.get_noise_2d(x, y)
			var enemy_value := spawner_noise.get_noise_2d(x, y)
			
			var tile_coords : Vector2i
			if world_value < -0.1:
				tile_coords = Vector2i(5, 0)
				if tree_value < -0.1:
					var local_pos := map.map_to_local(Vector2i(world_x, world_y))
					var global_pos := map.to_global(local_pos)
					new_trees.append(global_pos)
					#objects.set_cell(Vector2i(x, y), 2, Vector2i(0, 0))
			else:
				if enemy_value < -0.5:
					var local_pos := map.map_to_local(Vector2i(world_x, world_y))
					var global_pos := map.to_global(local_pos)
					new_spawners.append(global_pos)
				tile_coords = be_grass(grass_value)
			map.set_cell(Vector2i(world_x, world_y), 2, tile_coords)
	emit_signal("region_generated", new_trees, new_spawners)

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
