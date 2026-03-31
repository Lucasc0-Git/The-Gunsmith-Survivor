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
		if GameManager.is_night() and enemy.global_position.distance_to(enemy.the_core.global_position) < 2000:
			enemy.change_state("ChaseCore")

#func get_position_of_target() -> Vector2:
	#if GameManager.is_night():
		#return enemy.the_core.global_position
	#else:
		#return enemy.player.global_position
