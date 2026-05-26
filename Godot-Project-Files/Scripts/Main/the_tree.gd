extends CharacterBody2D

@onready var collision: CollisionShape2D = $CollisionShape2D
@onready var sprite: Sprite2D = $Sprite2D
@onready var ysort_node := get_parent()
@onready var main: Main = get_parent().get_parent()

@export var shake_player: AnimationPlayer
@export var damage_mulitpliers: Dictionary[DamageTypes.DamageType, float] = DamageTypes.get_default_damage_multipliers()

var health: float = 50
var wood_item : ItemData
var destroyed: bool = false

func _ready() -> void:
	if not ItemRegistry or not ItemRegistry.loaded:
		await ItemRegistry.items_loaded
	
	wood_item = ItemRegistry.items.get("wood")

func drop_items(amount: int, random_range: int) -> void:
	for i in range(amount):
		main.drop_item(wood_item, global_position, random_range)

func take_damage(amount: float, dmg_type: DamageTypes.DamageType) -> void:
	if destroyed: return
	var multiplier: float = damage_mulitpliers.get(dmg_type, 1.0)
	var damage := amount * multiplier
	
	health -= damage
	
	if health <= 0:
		destroy()
	else:
		play_shake(0.7 if dmg_type == DamageTypes.DamageType.LONG_RANGE else 1.0)

func play_shake(intensity: float = 1.0) -> void:
	shake_player.stop()
	shake_player.speed_scale = intensity
	shake_player.play("shake_on_hit")

func destroy() -> void:
	collision.set_deferred("disabled", true)
	drop_items(1, 20)
	if GameManager.random_bool():
		shake_player.play("fall_right")
	else:
		shake_player.play("fall_left")
	await shake_player.animation_finished
	queue_free()

func _on_visible_on_screen_notifier_2d_screen_entered() -> void:
	collision.set_deferred("disabled", false)

func _on_visible_on_screen_notifier_2d_screen_exited() -> void:
	collision.set_deferred("disabled", true)
