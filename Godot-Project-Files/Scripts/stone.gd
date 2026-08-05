extends MiningResource
class_name Stone


func take_damage(_amount: float, dmg_type: DamageTypes.DamageType, weapon_type: String = "Basic") -> void:
	if destroyed: return
	
	if dmg_type == DamageTypes.DamageType.MELEE:
		if weapon_type == "Pickaxe":
			if randf() > 0.4:
				drop_items(1, 50)
	sprite.modulate = Color(2, 2, 2)

	play_shake(0.7 if dmg_type == DamageTypes.DamageType.LONG_RANGE else 1.0)

func play_shake(intensity: float = 1.0) -> void:
	shake_player.stop()
	shake_player.speed_scale = intensity
	shake_player.play("shake_on_hit")

func destroy() -> void:
	GameManager.score += score_for_destroy
	GameManager.more_stats["Resources mined"] += 1
	collision.set_deferred("disabled", true)
	call_resource_destroyed()
	queue_free()
