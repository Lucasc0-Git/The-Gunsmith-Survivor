extends CharacterBody2D

@onready var collision: CollisionShape2D = $CollisionShape2D
@onready var sprite: Sprite2D = $Sprite2D
@onready var ysort_node := get_parent()
@onready var main: Main = get_parent().get_parent()

@export var shake_player: AnimationPlayer
@export var damage_mulitpliers: Dictionary[DamageTypes.DamageType, float] = DamageTypes.get_default_damage_multipliers()
@export var regen: float = 0.5
@export var max_health: float = 50
@export var health: float = 50
@export var full_health_modulate: Color = Color(1.0, 1.0, 1.0, 1.0)
@export var low_health_modulate: Color = Color(0.256, 0.256, 0.256, 1.0)

var target_color: Color
var wood_item : ItemData
var destroyed: bool = false

func _ready() -> void:
	if not ItemRegistry or not ItemRegistry.loaded:
		await ItemRegistry.items_loaded
	health = max_health
	update_target_color()
	
	wood_item = ItemRegistry.items.get("wood")

func drop_items(amount: int, random_range: int) -> void:
	for i in range(amount):
		main.drop_item(wood_item, global_position, random_range)

func take_damage(amount: float, dmg_type: DamageTypes.DamageType) -> void:
	if destroyed: return
	var multiplier: float = damage_mulitpliers.get(dmg_type, 1.0)
	var damage := amount * multiplier
	health -= damage
	update_target_color()
	if health <= 0:
		destroy()
	else:
		play_shake(0.7 if dmg_type == DamageTypes.DamageType.LONG_RANGE else 1.0)

func _process(delta: float) -> void:
	if health < max_health:
		health += regen * delta
		update_target_color()
	else:
		health = max_health
	sprite.modulate = sprite.modulate.lerp(target_color, 3.0 * delta)
	
	

func update_target_color() -> void:
	var health_ratio := health / max_health
	target_color = low_health_modulate.lerp(full_health_modulate, health_ratio)

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
