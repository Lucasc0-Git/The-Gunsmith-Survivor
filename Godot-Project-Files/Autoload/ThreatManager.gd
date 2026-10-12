extends Node

var spawners: Array = []
var current_enemy_count: int = 0

var base_needed_enemy_count: int = 8
var enemy_count_growth_per_score: float = 0.01
var soft_cap: int = 40
var target_enemy_count: int

var respawn_time: float = 5.0

var _last_score: int = 0x7FFFFFFF
var _time_accumulator: float = 0.0

func _process(delta: float) -> void:
	if not GameManager.is_game_loaded: return
	if not GameManager.is_night(): return
	if GameManager.score == _last_score: return
	_last_score = GameManager.score
	
	target_enemy_count = mini(base_needed_enemy_count + maxi(floori(GameManager.score * enemy_count_growth_per_score), 0), soft_cap)
	target_enemy_count = int(target_enemy_count * GameManager.difficulty_multiplier)
	
	if current_enemy_count < target_enemy_count:
		_time_accumulator += delta
		if _time_accumulator >= respawn_time:
			spawn_enemy()
			_time_accumulator -= respawn_time

func spawn_enemy() -> void:
	print("imagine spawning enemy")
