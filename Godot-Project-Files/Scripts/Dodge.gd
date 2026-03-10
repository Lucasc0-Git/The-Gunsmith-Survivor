extends State

var timer: Timer = Timer.new()

func _ready() -> void:
	add_child(timer)
	

func enter() -> void:
	print("doge entered")
	player.velocity += player.last_dir * player.DODGE_FORCE
	timer.start(1)
	await timer.timeout
	player.change_state("Run")

func physics_update(delta: float) -> void:
	
	player.velocity = player.velocity.move_toward(Vector2.ZERO, 350 * delta)
	
	if player.velocity == Vector2.ZERO:
		player.change_state("Idle")
