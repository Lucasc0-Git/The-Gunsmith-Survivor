extends State

var timer: Timer = Timer.new()

func _ready() -> void:
	add_child(timer)

func enter() -> void:
	player.velocity += player.input_dir * player.dodge_force
	timer.start(0.8)
	await timer.timeout
	player.change_state("Run")

func physics_update(delta: float) -> void:
	
	player.velocity = player.velocity.move_toward(Vector2.ZERO, 350 * delta)
	
	if player.velocity == Vector2.ZERO:
		player.change_state("Idle")
