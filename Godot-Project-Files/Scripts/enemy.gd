extends CharacterBody2D
class_name Enemy

@onready var attack_timer: Timer = $Timer
@onready var health_bar: ProgressBar = $HealthBar
@onready var states_node := $StateMachine

@export var speed: int = 50
@export var max_health: float = 40
@export var damage: float = 15

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
var player: Player = null
var current_state: State
var states := {}

func _ready() -> void:
	health_bar.visible = false
	health_bar.max_value = max_health
	health_bar.value = max_health
	health = max_health
	player = get_tree().get_first_node_in_group("player")
	
	## State machine
	for child in states_node.get_children():
		if child is State:
			states[child.name] = child
			child.player = self
	change_state("Idle")

## State machine
func change_state(state_name: String) -> void:
	if current_state:
		current_state.exit()
	current_state = states[state_name]
	current_state.enter()

func _physics_process(delta: float) -> void:
	if player == null: return
	move(delta)
	move_and_slide()
	
	if current_state:
		current_state.physics_update(delta)

func move(delta: float) -> void:
	var direction := global_position.direction_to(player.global_position)
	velocity = direction * speed

func take_damage(amount: float) -> void:
	health -= amount
	if health <= 0:
		die()

func die() -> void:
	queue_free()

func _on_timer_timeout() -> void:
	if player == null or !player_in_range: return
	player.get_hurt(damage)

func _on_hit_box_area_body_entered(body: Node2D) -> void:
	if body is Player:
		player_in_range = true

func _on_hit_box_area_body_exited(body: Node2D) -> void:
	if body is Player:
		player_in_range = false
