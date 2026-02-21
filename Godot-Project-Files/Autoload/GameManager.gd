extends Node
## Handle global things; autoload

var current_world_seed: int

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("exit"):
		#get_tree().quit()
		pass
