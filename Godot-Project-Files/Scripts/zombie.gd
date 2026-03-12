extends Enemy
class_name Zombie

@export var lunge_speed: int = 150

func move(delta: float) -> void:
	var distance := global_position.distance_to(player.global_position)
	var direction := global_position.direction_to(player.global_position)
	if distance < 25:
		return
	else:
		velocity = direction * speed

func die() -> void:
	#here goes dropping looooot.
	queue_free()
