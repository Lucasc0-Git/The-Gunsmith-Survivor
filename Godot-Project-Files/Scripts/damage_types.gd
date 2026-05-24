extends RefCounted
class_name DamageTypes

const TYPES: Array[String] = [
	"basic",
	"melee",
	"long_range"
]

const BASIC: String = "basic"
const MELEE: String = "melee"
const LONG_RANGE: String = "long_range"

const DAMAGE_TYPES_HINT: String = "basic,melee,long_range"

static func get_hint_string() -> String:
	return ",".join(TYPES)

static func is_valid(type: String) -> bool:
	return type in TYPES

static func get_all() -> Array[String]:
	return TYPES
