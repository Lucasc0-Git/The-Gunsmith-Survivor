extends BuildScene
class_name StationBuildScene

##The ID used in determining, which type of crafting station ts is.
@export var station_type: GameManager.StationType


func _on_crafting_area_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		if station_type not in body.nearby_stations:
			body.nearby_stations[station_type] = 0
		body.nearby_stations[station_type] += 1

func _on_crafting_area_body_exited(body: Node2D) -> void:
	if body.is_in_group("player"):
		if station_type in body.nearby_stations:
			body.nearby_stations[station_type] -= 1
			if body.nearby_stations[station_type] <= 0:
				body.nearby_stations.erase(station_type)
