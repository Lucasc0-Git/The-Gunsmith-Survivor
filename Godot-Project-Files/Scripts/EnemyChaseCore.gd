extends EnemyState




func physics_update(_delta: float) -> void:
	var dir := enemy.global_position.direction_to(enemy.the_core.global_position)
	var target_speed := dir * enemy.speed
	enemy.velocity = enemy.velocity.move_toward(target_speed, enemy.accel * _delta)
	
	if !GameManager.is_night():
		enemy.change_state("Wonder")
