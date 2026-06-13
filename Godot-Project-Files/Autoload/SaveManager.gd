extends Node

const SAVE_DIR = "user://saves/"
const CURRENT_VERSION = 1

signal save_list_changed()

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
	save_data = serialize_value(save_data)
	
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
	
	var raw_data: Dictionary = json.data
	var save_data: Dictionary = deserialize_value(raw_data)
	
	if save_data.get("version", -1) != GameManager.CURRENT_GAME_VERSION:
		push_warning("Save version mismatch for " + path + ". Continuing...")
	
	#GameManager.current_save_name = current_save_name
	#GameManager.is_loading_save = true
	
	_deserialize_game_manager(save_data.get("game_manager", {}))
	
	var game_manager_data: Dictionary = save_data.get("game_manager", {})
	GameManager.main.generate(int(game_manager_data.get("current_world_seed", 12)))
	
	if GameManager.main and GameManager.main.player:
		GameManager.main.player.load_data(save_data.get("player", {}))
	
	_deserialize_built_objects(save_data.get("built_objects", []))
	_deserialize_enemies(save_data.get("enemies", []))
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
		save_list_changed.emit()
		return true
	return false

# ========================= TYPE CONVERSION HELPERS ============================================

func vec2_to_dict(v: Vector2) -> Dictionary:
	return {"x": v.x, "y": v.y}

func dict_to_vec2(d: Variant) -> Vector2:
	if d is Dictionary:
		print("Convering " + str(d) + " as Vector2 with values: (%s, %s)" % [d.get("x", 0.0), d.get("y", 0.0)])
		return Vector2(
			float(d.get("x", 0.0)),
			float(d.get("y", 0.0))
		)
	else:
		print(str(d) + " is not a Dictionary.")
	return Vector2.ZERO

func serialize_value(value: Variant) -> Variant:
	if value is Vector2:
		return vec2_to_dict(value)
	if value is Array:
		return value.map(serialize_value)
	if value is Dictionary:
		var new_dict := {}
		for k: Variant in value:
			new_dict[k] = serialize_value(value[k])
		return new_dict
	if value is Object and value.has_method("save_data"):
		return value.save_data()
	return value

func deserialize_value(value: Variant) -> Variant:
	if value is Dictionary:
		if value.has("x") and value.has("y") and not value.has("z"):
			return dict_to_vec2(value)
		var new_dict := {}
		for k: Variant in value:
			new_dict[k] = deserialize_value(value[k])
		return new_dict
	if value is Array:
		return value.map(deserialize_value)
	if value is String:
		if value.is_valid_int():
			return int(value)
		if value.is_valid_float():
			return float(value)
		if value.begins_with("#"):
			return Color(value)
	return value



# ========================= HELP FUNCTIONS =====================================================

#GameManager
func _serialize_game_manager() -> Dictionary:
	return {
		"current_world_seed": GameManager.current_world_seed,
		"time": GameManager.time,
		"current_day": GameManager.current_day,
		"current_hour": GameManager.current_hour,
		"score": GameManager.score,
		"more_stats": GameManager.more_stats as Dictionary[String, int]
	}

func _deserialize_game_manager(data: Dictionary) -> void:
	GameManager.current_world_seed = data.get("current_world_seed", 12)
	print("Setting current_world_seed via loading the game: " + str(GameManager.current_world_seed))
	GameManager.time = data.get("time", 0.0)
	GameManager.set_day(data.get("current_day", 0))
	GameManager.set_hour(data.get("current_hour", 0))
	GameManager.score = data.get("score", 0)
	var loaded_stats: Dictionary = data.get("more_stats")
	if loaded_stats:
		GameManager.more_stats.clear()
		for key: String in loaded_stats.keys():
			if key is String and loaded_stats[key] is int:
				GameManager.more_stats[key] = loaded_stats[key]
			else:
				push_warning("Invalid stat data skipped: " + str(key))
	else:
		push_warning("more_stats invalid.")
	#GameManager.more_stats = data.get("more_stats", {"ERR": 84}) as Dictionary[String, int]
	
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

func _serialize_built_objects() -> Array:
	var data := []
	for child in GameManager.main.Ysort.get_children():
		if child.is_in_group("built") and child.has_method("save_data"):
			data.append(child.save_data())
	return data

func _deserialize_built_objects(data_array: Array) -> void:
	for child in GameManager.main.Ysort.get_children():
		if child.is_in_group("built"):
			child.queue_free()
	
	for dict: Dictionary in data_array:
		var scene_path: String = dict.get("scene_path", "")
		if scene_path.is_empty():
			continue
		
		var packed_scene: PackedScene = load(scene_path)
		if packed_scene:
			var instance := packed_scene.instantiate() as BuildScene
			if instance.has_method("load_data"):
				instance.load_data(dict)
			else:
				instance.global_position = dict_to_vec2(dict.get("position", {}))
			GameManager.main.Ysort.add_child(instance)
		else:
			push_error("Failed to load build scene: " + scene_path)

#Inventory

func _serialize_inventory() -> Array:
	if GameManager.main.hud.inventory:
		return GameManager.main.hud.inventory.save_data()
	return []

func _deserialize_inventory(data_array: Array) -> void:
	if GameManager.main.hud.inventory:
		GameManager.main.hud.inventory.load_data(data_array)

#Hotbar

func _serialize_hotbar() -> Array:
	if GameManager.main.hud.hotbar:
		return GameManager.main.hud.hotbar.save_data()
	return []

func _deserialize_hotbar(data_array: Array) -> void:
	if GameManager.main.hud.hotbar:
		GameManager.main.hud.hotbar.load_data(data_array)
