extends EnemyState

@onready var wonder_timer: Timer = $WonderTimer

var wonder_dir : Vector2 = Vector2.ZERO

func _ready() -> void:
	wonder_timer.timeout.connect(_on_wonder_timer_timeout)

func enter() -> void:
	if is_inside_tree():
		wonder_timer.start(1.5)

func exit() -> void:
	wonder_timer.stop()
	wonder_dir = Vector2.ZERO

func physics_update(delta: float) -> void:
	enemy.velocity = enemy.velocity.move_toward(wonder_dir * enemy.wonder_speed, enemy.accel * delta)
	
	if enemy.global_position.distance_to(enemy.player.global_position) < enemy.chase_range:
		enemy.change_state("Chase")
	if GameManager.is_night() and enemy.global_position.distance_to(enemy.the_core.global_position) < 2000:
		enemy.change_state("ChaseCore")

func _on_wonder_timer_timeout() -> void:
	if is_inside_tree():
		wonder_timer.start(randf_range(2, 5))
	wonder_dir = Vector2.from_angle(randf_range(0, TAU))
