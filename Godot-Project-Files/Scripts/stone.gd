extends MiningResource
class_name Stone

@export var drop_weights: Dictionary = { # Dictionary where keys are item IDs and values are the weights.
	"stone": 0.0,
	"iron_ore": 0.0,
	"copper_ore": 0.0,
	"gold_ore": 0.0,
	"platinum": 0.0
}

var rng: RandomNumberGenerator = RandomNumberGenerator.new()
var materials: Array[String] = []
var weights: PackedFloat32Array = []

func _ready() -> void:
	super()
	_rebuild_weight_table()
	rng.randomize()

func _rebuild_weight_table() -> void:
	materials.clear()
	weights.clear()
	for _material: String in drop_weights:
		materials.append(_material)
		weights.append(drop_weights[_material])

func get_random_material() -> String: # returns the item's ID
	if materials.is_empty():
		return "stone"
	var index := rng.rand_weighted(weights)
	return materials[index]

func take_damage(_amount: float, dmg_type: DamageTypes.DamageType, weapon_type: String = "Basic") -> void:
	if destroyed: return
	
	if dmg_type == DamageTypes.DamageType.MELEE:
		if weapon_type == "Pickaxe":
			var random_item_id: String = get_random_material()
			var dropped_item_data: ItemData = get_item_data(random_item_id)
			main.drop_item(dropped_item_data, global_position, 50)
	
	sprite.modulate = Color(2, 2, 2)

	play_shake(0.7 if dmg_type == DamageTypes.DamageType.LONG_RANGE else 1.0)
	set_process(true)

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
