extends MiningResource
class_name TheTree

#func _ready() -> void:
	#if not ItemRegistry or not ItemRegistry.loaded:
		#await ItemRegistry.items_loaded
	#health = max_health
	#update_target_color()
	#
	#wood_item = ItemRegistry.items.get("wood")
#
#func drop_items(amount: int, random_range: int) -> void:
	#for i in range(amount):
		#main.drop_item(wood_item, global_position, random_range)
#
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
#
#func _process(delta: float) -> void:
	#if !GameManager.is_game_loaded: return
	#if health < max_health:
		#health += regen * delta
		#update_target_color()
	#else:
		#health = max_health
	#sprite.modulate = sprite.modulate.lerp(target_color, 3.0 * delta)
	#
		#
#
#func update_target_color() -> void:
	#var health_ratio := health / max_health
	#target_color = low_health_modulate.lerp(full_health_modulate, health_ratio)
#
func play_shake(intensity: float = 1.0) -> void:
	shake_player.stop()
	shake_player.speed_scale = intensity
	shake_player.play("shake_on_hit")

func destroy() -> void:
	GameManager.score += score_for_destroy
	GameManager.more_stats["Resources mined"] += 1
	collision.set_deferred("disabled", true)
	drop_items(1, 20)
	if GameManager.random_bool():
		shake_player.play("fall_right")
	else:
		shake_player.play("fall_left")
	await shake_player.animation_finished
	queue_free()

#func _on_visible_on_screen_notifier_2d_screen_entered() -> void:
	#collision.set_deferred("disabled", false)
#
#func _on_visible_on_screen_notifier_2d_screen_exited() -> void:
	#collision.set_deferred("disabled", true)
