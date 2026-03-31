extends State
## The idle state (player dont move, don't do anything)

## Called on function enter
func enter() -> void:
	## Start playing the idle animation
	var last_dir: Vector2 = player.last_dir
	match last_dir:
		Vector2.LEFT:
			player.anim_player.flip_h = true
			player.anim_player.play("IdleSide")
		Vector2.RIGHT:
			player.anim_player.flip_h = false
			player.anim_player.play("IdleSide")
		Vector2.UP:
			player.anim_player.flip_h = false
			player.anim_player.play("IdleUp")
		Vector2.DOWN:
			player.anim_player.flip_h = false
			player.anim_player.play("IdleDown")

## Called every physics frame
func physics_update(_delta: float) -> void:
	
	## Change state to "run" if moving
	if player.target_speed != Vector2.ZERO:
		player.change_state("Run")
