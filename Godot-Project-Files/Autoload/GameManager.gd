extends Node
## Handle global things; autoload

enum StationType {
	BASIC_CRAFTING,
	BASIC_SMITHING_TABLE
	#Here more stations
}

enum Difficulty {
	EASY = 0,
	SLIGHTLY_CHALLENGING = 1,
	NORMAL = 2,
	CHALLENGING = 3,
	DIFFICULT = 4,
	NIGHTMARE = 5
}

const STATION_NAMES: Dictionary[StationType, String] = {
	StationType.BASIC_CRAFTING: "Basic station",
	StationType.BASIC_SMITHING_TABLE: "Basic smithing table"
	#Here add to every station type its string name
}


const CURRENT_GAME_VERSION = 1

const DAMAGE_TYPES: Array[String] = DamageTypes.TYPES

const BASE_HOURLY_POINTS: int = 5
const SCORE_MULTIPLIER: float = 1.2
const BASE_DAILY_POINTS: int = 15
const MAX_DAILY_POINTS: int = 400 ##A cap for the exponential calculating of points based on days survived.

var current_world_seed: int
var current_save_name: String = ""
var time: float = 0.0
var day_length: float = 600.0
var current_hour: int = 0
var current_day: int = 0
var main: Main = null
var is_game_loaded: bool = false
var is_loading_save: bool = false
var pending_save_name: String = ""
var spawner_activity_mult: float = 1.0
var selected_difficulty: Difficulty = Difficulty.NORMAL ## Preset chosen by the player
var difficulty_multiplier: float = 1.0 ## The multiplier of everything based on the chosen preset

var score: int = 0
var more_stats: Dictionary = {
	"Deaths": 0,
	"Enemies killed": 0,
	"Items crafted": 0,
	"Resources mined": 0,
	"Buildings built": 0
}

signal hour_changed(hour: int)
signal day_changed(day: int)

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS

func _process(delta: float) -> void:
	if !is_game_loaded: return
	if get_tree().paused: return
	time += delta
	
	
	
	
	var new_hour := int((time / day_length) * 24) % 24
	if new_hour != current_hour:
		score += BASE_HOURLY_POINTS
		current_hour = new_hour
		hour_changed.emit(current_hour)
	
	var new_day := int(time / day_length)
	if new_day != current_day:
		score += int(BASE_DAILY_POINTS * (SCORE_MULTIPLIER ** (new_day - 1)))
		current_day = new_day
		day_changed.emit(current_day)

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("exit"):
		#get_tree().quit()
		pass

func is_night() -> bool:
	return true if current_hour >= 20 or current_hour < 6 else false

func set_hour(hour: int) -> void:
	# keep the current day, just change the hour
	var day_progress := float(hour) / 24.0
	time = current_day * day_length + day_progress * day_length
	current_hour = hour
	hour_changed.emit(current_hour)

func set_day(day: int) -> void:
	# keep the current hour, just change the day
	time = day * day_length + (float(current_hour) / 24.0) * day_length
	current_day = day
	day_changed.emit(current_day)

func has_required_stations(item: ItemData) -> bool:
	for station_type in item.needed_stations:
		if main.player.nearby_stations.get(station_type, 0) < item.needed_stations[station_type]:
			return false
	return true

func has_this_station(station_type: StationType) -> bool:
	if main.player.nearby_stations.get(station_type, 0) <= 0:
		return false
	return true

func get_station_name(station_type: StationType) -> String:
	return STATION_NAMES.get(station_type, "ERROR: Unknown station!")

func random_bool() -> bool:
	return randf() < 0.5

func random_choice(option_a: Variant, option_b: Variant) -> Variant:
	return option_a if randf() < 0.5 else option_b

func wait_for_node(node: Node, timeout: float = 2.0) -> bool:
	if not node:
		return false
	
	var start_time := Time.get_ticks_msec()
	
	while not node.is_inside_tree() or not node.is_node_ready():
		if Time.get_ticks_msec() - start_time > timeout * 1000:
			push_warning("Timeout waiting for node: %s" % node.name)
			return false
		await get_tree().process_frame
	
	return true

func get_multiplier_for_difficulty(diff: Difficulty) -> float:
	match diff:
		Difficulty.EASY:
			return 0.75
		Difficulty.SLIGHTLY_CHALLENGING:
			return 0.9
		Difficulty.NORMAL:
			return 1.0
		Difficulty.CHALLENGING:
			return 1.2
		Difficulty.DIFFICULT:
			return 1.35
		Difficulty.NIGHTMARE:
			return 1.8
		_:
			push_warning("Unknown difficulty preset! Using NORMAL")
			return 1.0

func start_new_world(difficulty_preset: Difficulty = Difficulty.NORMAL) -> void:
	is_loading_save = false
	current_world_seed = randi()
	difficulty_multiplier = get_multiplier_for_difficulty(difficulty_preset)
	main = preload("res://Scenes/Main.tscn").instantiate()
	get_tree().change_scene_to_node(main)

func load_world(save_name: String, difficulty_preset: Difficulty = Difficulty.NORMAL) -> void:
	is_loading_save = true
	pending_save_name = save_name
	current_save_name = save_name
	difficulty_multiplier = get_multiplier_for_difficulty(difficulty_preset)
	main = preload("res://Scenes/Main.tscn").instantiate()
	get_tree().change_scene_to_node(main)
