extends CharacterBody2D
class_name Enemy

@onready var attack_timer: Timer = $Timer

@export var speed: int = 50
@export var health: float = 40
@export var damage: float = 15

var player_in_range: bool = false
var player: Player = null

func _ready() -> void:
	player = get_tree().get_first_node_in_group("player")

func _physics_process(delta: float) -> void:
	if player == null: return
	move(delta)
	move_and_slide()

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
