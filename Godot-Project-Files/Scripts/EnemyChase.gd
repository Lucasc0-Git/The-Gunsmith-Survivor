extends EnemyState

func enter() -> void:
	pass

func exit() -> void:
	pass

func physics_update(delta: float) -> void:
	var dir := enemy.global_position.direction_to(enemy.player.global_position)
	var target_speed := dir * enemy.speed
	enemy.velocity = enemy.velocity.move_toward(target_speed, enemy.accel * delta)
	
	if !enemy.chase_forced:
		if enemy.global_position.distance_to(enemy.player.global_position) > enemy.chase_range:
			enemy.change_state("Wonder")
