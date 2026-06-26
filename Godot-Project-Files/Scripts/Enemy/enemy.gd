extends CharacterBody2D
class_name Enemy

@onready var attack_timer: Timer = $Timer
@onready var health_bar: ProgressBar = $HealthBar
@onready var states_node := $StateMachine
@onready var despawn_timer: Timer = $DespawnTimer

@export var speed: int = 50
@export var wonder_speed: int = 20
@export var max_health: float = 40
@export var damage: float = 15
@export var accel: int = 300
@export var chase_range: int = 400
@export var damage_multipliers: Dictionary[DamageTypes.DamageType, float] = DamageTypes.get_default_damage_multipliers()
@export var score_for_kill: int = 15
@export var damage_type: DamageTypes.DamageType
@export var despawn_time: float = 60 * 4

var health: float = 10:
	get():
		return _health
	set(value):
		value = clamp(value, 0, max_health)
		_health = value
		if is_node_ready():
			health_bar.value = value
			if value < max_health:
				health_bar.visible = true

var _health: float
var player_in_range: bool = false
var core_in_range: bool = false
var player: Player = null
var current_state: EnemyState
var states := {}
var delta: float
var chase_forced: bool = false
var the_core: TheCore
var main: Main
#var chasing_core: bool = false

func _ready() -> void:
	despawn_timer.timeout.connect(_on_despawn_timer_timeout)
	despawn_timer.start(despawn_time)
	health_bar.visible = false
	health_bar.max_value = max_health
	health_bar.value = max_health
	health = max_health
	player = get_tree().get_first_node_in_group("player")
	the_core = get_tree().get_first_node_in_group("thecore")
	main = GameManager.main
	
	## State machine
	for child in states_node.get_children():
		if child is EnemyState:
			states[child.name] = child
			child.enemy = self
	change_state("Wonder")

## State machine
func change_state(state_name: String) -> void:
	if current_state:
		current_state.exit()
	current_state = states[state_name]
	current_state.enter()

func _physics_process(_delta: float) -> void:
	if player == null: return
	delta = _delta
	move_and_slide()
	
	if current_state:
		current_state.physics_update(delta)

func _on_despawn_timer_timeout() -> void:
	queue_free()

func get_target() -> Node2D: ##Returns player, the core, OR null.
	if player_in_range:
		return player
	elif core_in_range:
		return the_core
	return null

func stop_moving() -> void:
	velocity = velocity.move_toward(Vector2.ZERO, accel)

func take_damage(amount: float, dmg_type: DamageTypes.DamageType, _weapon_type: String = "Basic") -> void:
	var multiplier: float = damage_multipliers.get(dmg_type, 1.0)
	var taking_damage := amount * multiplier
	
	chase_forced = true
	change_state("Chase")
	health -= taking_damage
	if health <= 0:
		die()

func die() -> void:
	GameManager.score += score_for_kill
	GameManager.more_stats["Enemies killed"] += 1
	queue_free()

func _on_timer_timeout() -> void:
	if (player_in_range or core_in_range) and current_state.name == "Hit":
		attack()
		attack_timer.start()

func _on_attack_range_area_body_entered(body: Node2D) -> void:
	if body is Player:
		change_state("Hit")
		player_in_range = true
		await get_tree().create_timer(0.3).timeout
		attack()
		attack_timer.start()
	if body is TheCore:
		change_state("Hit")
		core_in_range = true
		attack()
		attack_timer.start()

func _on_attack_range_area_body_exited(body: Node2D) -> void:
	if body is Player:
		change_state("Chase")
		player_in_range = false
	if body is TheCore:
		change_state("Wonder")
		core_in_range = false

func attack() -> void:
	var target := get_target()
	if !target: return
	target.take_damage(damage, damage_type)

func save_data() -> Dictionary:
	return {
		"scene_path": scene_file_path,
		"position": global_position,
		"health": health,
		"chase_forced": chase_forced,
		"player_in_range": player_in_range,
		"core_in_range": core_in_range,
		"current_state_name": current_state.name if current_state else &"Wonder", # StringName, is faster for comparising
	}

func load_data(data: Dictionary) -> void:
	global_position = SaveManager.dict_to_vec2(data.get("position"))
	health = float(data.get("health", max_health))
	chase_forced = bool(data.get("chase_forced", false))
	player_in_range = bool(data.get("player_in_range", false))
	core_in_range = bool(data.get("core_in_range", false))
	if data.has("current_state_name"):
		var state_name: StringName = data.get("current_state_name", &"Wonder")
		change_state(state_name)
	velocity = Vector2.ZERO
