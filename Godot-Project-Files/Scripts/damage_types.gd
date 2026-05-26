extends RefCounted
class_name DamageTypes

const TYPES: Array[String] = [
	"basic",
	"melee",
	"long_range"
]

enum DamageType {
	BASIC,
	MELEE,
	LONG_RANGE
}

const BASIC: String = "basic"
const MELEE: String = "melee"
const LONG_RANGE: String = "long_range"

const DAMAGE_TYPES_HINT: String = "basic,melee,long_range"

static func damage_type_to_string(type: DamageType) -> String:
	match type:
		DamageType.BASIC:      return "basic"
		DamageType.MELEE:      return "melee"
		DamageType.LONG_RANGE: return "long_range"
		_:                     return "basic"

static func get_hint_string() -> String:
	return ",".join(TYPES)

static func is_valid(type: String) -> bool:
	return type in TYPES

static func get_all() -> Array[String]:
	return TYPES

static func get_default_damage_multipliers() -> Dictionary[DamageType, float]:
	var dict: Dictionary[DamageType, float] = {}
	for type: DamageType in DamageType.values():
		dict[type] = 1.0
	return dict
