extends Node2D
class_name Spawner

@onready var marker: Marker2D = $Marker2D
@onready var disable_area: Area2D = $DisableArea ##A circle, when there is player in this circle, the spawner will be deactivated.

var main: Main
var spawner_disabled: bool = false

func _ready() -> void:
	pass

func spawn_enemy(forced: bool = false) -> void:
	if !spawner_disabled or forced:
		var enemy := main.zombie_scene.instantiate()
		enemy.global_position = marker.global_position
		main.Ysort.add_child(enemy)

func _on_disable_area_body_entered(body: Node2D) -> void:
	if body is Player:
		spawner_disabled = true

func _on_disable_area_body_exited(body: Node2D) -> void:
	if body is Player:
		spawner_disabled = false
