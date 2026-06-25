extends Node2D
class_name Spawner

@export var spawn_time_randomizer: float = 40
@export var spawn_cooldown_time: float = 120

@onready var marker: Marker2D = $Marker2D
@onready var disable_area: Area2D = $DisableArea ##A circle, when there is player in this circle, the spawner will be deactivated.
@onready var spawn_timer: Timer = $SpawnTimer

var distance_to_core: float = 0
var main: Main
var spawner_disabled: bool = false

func _ready() -> void:
	spawn_timer.wait_time = spawn_cooldown_time
	if OS.is_debug_build():
		$ColorRect.visible = true
	else:
		$ColorRect.visible = false
	
	while !GameManager.is_game_loaded:
		await get_tree().process_frame
	distance_to_core = marker.global_position.distance_to(GameManager.main.the_core.global_position)
	await get_tree().create_timer(45).timeout
	spawn_timer.wait_time += randf_range(-spawn_time_randomizer, spawn_time_randomizer)
	spawn_timer.start()

func _on_spawn_timer_timeout() -> void:
	if GameManager.random_bool():
		spawn_enemy(false)
	var base_wait_time: float = spawn_cooldown_time + randf_range(-spawn_time_randomizer, spawn_time_randomizer)
	spawn_timer.start(clamp(base_wait_time / (GameManager.spawner_activity_mult * GameManager.difficulty_multiplier), 20.0, base_wait_time + 30.0))

func spawn_enemy(forced: bool = false) -> void:
	if !spawner_disabled or forced:
		var enemy: Enemy = main.zombie_scene.instantiate()
		enemy.max_health += distance_to_core * (0.005 * GameManager.difficulty_multiplier)
		enemy.damage += distance_to_core * (0.001 * GameManager.difficulty_multiplier)
		enemy.score_for_kill += int(distance_to_core * (0.001 * GameManager.difficulty_multiplier))
		enemy.global_position = marker.global_position
		main.Ysort.add_child(enemy)

func _on_disable_area_body_entered(body: Node2D) -> void:
	if body is Player:
		spawner_disabled = true

func _on_disable_area_body_exited(body: Node2D) -> void:
	if body is Player:
		spawner_disabled = false
