extends ItemData
class_name WeaponItemData

@export var weapon_data: WeaponData

var current_heat: float = 0.0
var last_cooled_time: float = 0.0

func is_rotatable() -> bool:
	return weapon_data.rotatable

func update_heat(delta_time: float = -1.0) -> void:
	if !weapon_data or !weapon_data.heated:
		current_heat = 0.0
		return
	
	var current_time := Time.get_unix_time_from_system()
	
	if delta_time < 0:
		delta_time = current_time - last_cooled_time
	
	if delta_time > 0:
		current_heat -= weapon_data.heat_conductivity * delta_time
		current_heat = max(current_heat, 0.0)
	
	last_cooled_time = current_time
