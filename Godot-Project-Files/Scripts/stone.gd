extends MiningResource
class_name Stone

@export var base_drop_chance := 0.1
@export var damage_scaling := 0.02
@export var max_drop_chance_per_hit := 0.8

func take_damage(amount: float, dmg_type: DamageTypes.DamageType, weapon_type: String = "Basic") -> void:
	if destroyed: return
	var multiplier: float = damage_mulitpliers.get(dmg_type, 1.0)
	var damage := amount * multiplier
	
	if item_data and damage > 10:
		var drop_chance := base_drop_chance + (damage * damage_scaling)
		drop_chance = clamp(drop_chance, 0.0, max_drop_chance_per_hit)
		if weapon_type != "Pickaxe":
			drop_chance /= 4
			damage *= 0.8
		if randf() < drop_chance:
			drop_items(1, 35)
	
	health -= damage
	update_target_color()
	if health <= 0:
		destroy()
	else:
		play_shake(0.7 if dmg_type == DamageTypes.DamageType.LONG_RANGE else 1.0)

func play_shake(intensity: float = 1.0) -> void:
	shake_player.stop()
	shake_player.speed_scale = intensity
	shake_player.play("shake_on_hit")

func destroy() -> void:
	GameManager.score += score_for_destroy
	GameManager.more_stats["Resources mined"] += 1
	collision.set_deferred("disabled", true)
	drop_items(10, 50)
	shake_player.play("break")
	await shake_player.animation_finished
	call_resource_destroyed()
	queue_free()
