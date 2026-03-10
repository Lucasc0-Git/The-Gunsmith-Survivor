extends State
## The run state (player moves)

func enter() -> void:
	print("run entered")

## Called every physics frame
func physics_update(_delta: float) -> void:
	var dir : Vector2 = player.get_input_dir()
	match dir:
		Vector2.LEFT:
			player.anim_player.flip_h = true
			player.anim_player.play("RunSide")
			player.last_dir = Vector2.LEFT
		Vector2.DOWN:
			player.anim_player.flip_h = false
			player.anim_player.play("RunDown")
			player.last_dir = Vector2.DOWN
		Vector2.UP:
			player.anim_player.flip_h = false
			player.anim_player.play("RunUp")
			player.last_dir = Vector2.UP
		Vector2.RIGHT:
			player.anim_player.flip_h = false
			player.anim_player.play("RunSide")
			player.last_dir = Vector2.RIGHT
	
	## Change state to "idle" when not moving
	if dir == Vector2.ZERO and player.velocity == Vector2.ZERO:
		player.change_state("Idle")
	
	if Input.is_action_just_pressed("Dodge"):
		player.change_state("Dodge")
