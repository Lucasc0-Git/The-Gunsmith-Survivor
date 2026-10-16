extends Node
class_name GridUtils

const TILE_SIZE := Vector2i(16, 16)
const CHUNK_SIZE := 8
const MAP_ORIGIN := Vector2.ZERO
const MAP_SCALE := 3.0

static func global_to_tile(global_pos: Vector2) -> Vector2i:
	var local := global_pos - MAP_ORIGIN
	return Vector2i((local / Vector2(TILE_SIZE * MAP_SCALE)).floor())

static func tile_to_chunk(tile_pos: Vector2i) -> Vector2i:
	return Vector2i(
		floori(tile_pos.x / float(CHUNK_SIZE)),
		floori(tile_pos.y / float(CHUNK_SIZE))
	)

static func tile_to_local(tile_pos: Vector2i) -> Vector2i:
	return Vector2i(
		posmod(tile_pos.x, CHUNK_SIZE),
		posmod(tile_pos.y, CHUNK_SIZE)
	)

static func global_pos_to_local_tile(global_pos: Vector2) -> Vector2i:
	return tile_to_local(global_to_tile(global_pos))

#static func local_tile_to_global_pos(chunk_coords: Vector2i, tile_pos: Vector2i) -> Vector2:
	#pass

static func get_chunk_coords(pos: Vector2) -> Vector2i:
	return tile_to_chunk(global_to_tile(pos))
