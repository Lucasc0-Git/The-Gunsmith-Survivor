extends EnemyState

func enter() -> void:
	enemy.attack_timer.start()
	enemy.stop_moving()

func exit() -> void:
	enemy.attack_timer.stop()

func physics_update(_delta: float) -> void:
	pass
