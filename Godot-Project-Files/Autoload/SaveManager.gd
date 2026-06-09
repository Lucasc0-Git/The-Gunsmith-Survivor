extends Node

const SAVE_DIR = "user://saves/"
const CURRENT_VERSION = 1

var current_save_name: String = "save_slot_1"

func _ready() -> void:
	DirAccess.make_dir_absolute(SAVE_DIR)
	process_mode = Node.PROCESS_MODE_ALWAYS

# ========================== CORE SAVE/LOAD =======================================================

func save_game(save_name: String = "") -> bool:
	if save_name:
		current_save_name = save_name
	var path := SAVE_DIR + current_save_name + ".json"
	
	GameManager.current_save_name = current_save_name
	var save_data: Dictionary = {
		"version": CURRENT_VERSION, 
		"timestamp": Time.get_unix_time_from_system(),
		"game_manager": _serialize_game_manager(),
		"player": GameManager.main.player.save_data() if GameManager.main and GameManager.main.player else {},
		"enemies": _serialize_enemies(),
		"built_objects": _serialize_built_objects(),
		"inventory": _serialize_inventory(),
		"hotbar": _serialize_hotbar()
	}
	
	var file := FileAccess.open(path, FileAccess.WRITE)
	if file:
		file.store_string(JSON.stringify(save_data, "\t", true))
		print("Game saved to: ", path)
		return true
	push_error("Failed to save: ", path)
	return false

func load_save(save_name: String = "") -> bool:
	if save_name:
		current_save_name = save_name
	var path := SAVE_DIR + current_save_name + ".json"
	
	if not FileAccess.file_exists(path):
		push_warning("Save file not found: " + path)
		return false
	
	var file := FileAccess.open(path, FileAccess.READ)
	var json_text := file.get_as_text()
	var json := JSON.new()
	var error := json.parse(json_text)
	if error != OK:
		push_error("JSON parse error: " + json.get_error_message())
		return false
	
	var save_data: Dictionary = json.data
	
	if save_data.get("version", -1) != GameManager.CURRENT_GAME_VERSION:
		push_warning("Save " + path + "is not in the same version of the game. Continuing...")
	
	GameManager.current_save_name = current_save_name
	
	_deserialize_game_manager(save_data.get("game_manafer", {}))
	
	if GameManager.main and GameManager.main.player:
		GameManager.main.player.load_data(save_data.get("player", {}))
	
	_deserialize_enemies(save_data.get("enemies", []))
	_deserialize_built_objects(save_data.get("built_objects", []))
	_deserialize_inventory(save_data.get("inventory", {}))
	_deserialize_hotbar(save_data.get("hotbar", {}))
	
	print("Game loaded from: ", path)
	GameManager.is_game_loaded = true
	return true

func get_all_saves() -> Array[Dictionary]:
	var saves: Array[Dictionary] = []
	var dir := DirAccess.open(SAVE_DIR)
	if dir:
		dir.list_dir_begin()
		var file_name := dir.get_next()
		while file_name != "":
			if file_name.ends_with(".json"):
				var path := SAVE_DIR + file_name
				var file := FileAccess.open(path, FileAccess.READ)
				if file:
					var data: Variant = JSON.parse_string(file.get_as_text())
					if data:
						saves.append({
							"name": file_name.get_basename(),
							"timestamp": data.get("timestamp", 0),
							"path": path
						})
			file_name = dir.get_next()
	saves.sort_custom(func(a: Dictionary, b: Dictionary) -> bool: return a.timestamp < b.timestamp)
	return saves

func delete_save(save_name: String) -> bool:
	var path := SAVE_DIR + save_name + ".json"
	if DirAccess.remove_absolute(path) == OK:
		print("Deleted save: ", save_name)
		return true
	return false

# ================= Help functions ==============

#GameManager
func _serialize_game_manager() -> Dictionary:
	return {
		"current_world_seed": GameManager.current_world_seed,
		"time": GameManager.time,
		"current_day": GameManager.current_day,
		"current_hour": GameManager.current_hour,
		"score": GameManager.score,
		"more_stats": GameManager.more_stats
	}

func _deserialize_game_manager(data: Dictionary) -> void:
	GameManager.current_world_seed = data.get("current_world_seed", 0)
	GameManager.time = data.get("time", 0.0)
	GameManager.set_day(data.get("current_day", 0))
	GameManager.set_hour(data.get("current_hour", 0))
	GameManager.score = data.get("score", 0)
	GameManager.more_stats = data.get("more_stats", {"ERR": "Data Corrupted!"})

#Enemies

func _serialize_enemies() -> Array:
	var enemies_data := []
	var enemies := get_tree().get_nodes_in_group("enemy")
	for enemy in enemies:
		if is_instance_valid(enemy) and enemy.has_method("save_data"):
			enemies_data.append(enemy.save_data())
	return enemies_data

func _deserialize_enemies(data_array: Array) -> void:
	for enemy in get_tree().get_nodes_in_group("enemy"):
		if is_instance_valid(enemy): enemy.queue_free()
	
	for data: Dictionary in data_array:
		var enemy_scene: PackedScene = load(data.get("scene_path", "res://Scenes/zombie.tscn"))
		var enemy := enemy_scene.instantiate()
		GameManager.main.Ysort.add_child(enemy)
		#GameManager.main.spawn_enemy(enemy_scene, data.get("position", Vector2(0, 0)))
		enemy.load_data(data)

#Built objects

func _serialize_built_objects():
	pass

func _deserialize_built_objects(data):
	pass

#Inventory

func _serialize_inventory():
	pass

func _deserialize_inventory(data):
	pass

#Hotbar

func _serialize_hotbar():
	pass

func _deserialize_hotbar(data):
	pass
