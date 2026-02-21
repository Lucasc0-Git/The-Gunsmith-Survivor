extends Area2D
class_name BasicBullet

## The @export var declaration
@export var bullet_speed : float = 1100
@export var damping : float = 0 ##The deceleration of the bullet over time, 0 is no deceleration, 1.0 is complete stop.
@export var shrinking_rate : float = 0.99

## The @onready var declaration
@onready var despawn_timer: Timer = $DespawnTimer
@onready var hit_explosion: CPUParticles2D = $HitParticles
@onready var sprite: Sprite2D = $Sprite2D
@onready var collision_shape: CollisionShape2D = $CollisionShape2D

## The basic var declaration
var direction := Vector2.ZERO

func _ready() -> void:
	## Start the timer for despawn
	despawn_timer.start()

func _physics_process(delta: float) -> void:
	## Move the bullet
	if direction != Vector2.ZERO:
		position += direction.normalized() * bullet_speed * delta
		bullet_speed = max(0, bullet_speed * (1.0 - damping * delta))
	scale = scale * shrinking_rate
	if scale <= Vector2(0.00001, 0.00001):
		queue_free()
	#move_local_x(bullet_speed * delta)

## Called so the bullet will despawn
func _on_despawn_timer_timeout() -> void:
	queue_free()

## Called when bullet hits something (can recognise the group of the object)
func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("object"):
		hit_explosion.emitting = true
		sprite.visible = false
		collision_shape.set_deferred("disabled", true)
		await hit_explosion.finished
		queue_free()
		
