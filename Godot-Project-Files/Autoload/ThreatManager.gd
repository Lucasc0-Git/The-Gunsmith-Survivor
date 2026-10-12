extends Node

var main: Main

var spawners: Array = []
var current_enemy_count: int = 0

var base_needed_enemy_count: int = 10
var enemy_count_growth_per_score: float = 0.025
var soft_cap: int = 40
var target_enemy_count: int

var respawn_time: float = 2.5

var _last_score: int = 0x7FFFFFFF
var _time_accumulator: float = 0.0

func _process(delta: float) -> void:
	if not GameManager.is_game_loaded: return
	if not main:
		main = GameManager.main
	if not GameManager.is_night(): return
	if get_tree().paused: return
	
	if GameManager.score != _last_score:
		_last_score = GameManager.score
		target_enemy_count = mini(base_needed_enemy_count + maxi(floori(GameManager.score * enemy_count_growth_per_score), 0), soft_cap)
		target_enemy_count = int(target_enemy_count * GameManager.difficulty_multiplier)
	
	if current_enemy_count < target_enemy_count:
		_time_accumulator += delta
		if _time_accumulator >= respawn_time:
			spawn_enemy_at_best_spawner()
			_time_accumulator -= respawn_time

func _spawn_enemy(pos: Vector2) -> void:
	var enemy: Enemy = main.zombie_scene.instantiate()
	enemy.global_position = pos
	enemy.max_health *= GameManager.difficulty_multiplier
	enemy.speed *= int(1.0 + (GameManager.difficulty_multiplier - 1.0) * 0.7) # or enemy.speed *= lerp(1.0, GameManager.difficulty_multiplier, 0.5)
	enemy.score_for_kill = int(float(enemy.score_for_kill) * GameManager.difficulty_multiplier)
	enemy.damage *= GameManager.difficulty_multiplier
	
	current_enemy_count += 1
	enemy.tree_exiting.connect(func() -> void: current_enemy_count -= 1)
	
	main.Ysort.add_child(enemy)

func spawn_enemy_at_best_spawner() -> void:
	if not main or spawners.is_empty(): return
	
	var player_pos: Vector2 = main.player.global_position
	var active_spawners : Array = get_active_spawners()
	
	if active_spawners.is_empty(): return
	
	var weights : Array[float] = []
	var total_weight : float = 0.0
	
	for spawner: Spawner in active_spawners:
		var w: float = calculate_spawner_weight(spawner, player_pos)
		weights.append(w)
		total_weight += w
	
	if total_weight == 0.0: return
	
	var roll: float = randf() * total_weight
	var current_sum: float = 0.0
	var chosen_spawner: Spawner = null
	
	for i in range(active_spawners.size()):
		current_sum += weights[i]
		if roll <= current_sum:
			chosen_spawner = active_spawners[i]
			break
	
	if chosen_spawner:
		_spawn_enemy(chosen_spawner.global_position)

func get_active_spawners() -> Array:
	if not main: return []
	var active: Array = []
	
	var lights: Array = []
	for node: Node2D in get_tree().get_nodes_in_group("light_sources"):
		if node is BuildScene:
			lights.append(node)
	
	for spawner: Spawner in spawners:
		if spawner.global_position.distance_to(main.player.global_position) > 350:
			var light_near: bool = false
			for light: BuildScene in lights:
				if light.global_position.distance_to(spawner.global_position) < 80:
					light_near = true
					break
			
			if not light_near:
				active.append(spawner)
	return active

func calculate_spawner_weight(spawner: Spawner, player_pos: Vector2) -> float:
	var distance: float = spawner.global_position.distance_to(player_pos)
	const TARGET_DIST: float = 350.0
	const MAX_DIST: float = 6000.0 # Distance where chance drops to 0%
	
	if distance <= TARGET_DIST:
		return 0.0
	
	elif distance < MAX_DIST:
		return remap(distance, TARGET_DIST, MAX_DIST, 1.0, 0.0)
	
	return 0.0
