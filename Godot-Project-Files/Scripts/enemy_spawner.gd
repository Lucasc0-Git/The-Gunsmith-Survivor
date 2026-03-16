extends Node2D
class_name Spawner

@onready var marker: Marker2D = $Marker2D

var main: Main

func _ready() -> void:
	pass

func spawn_enemy() -> void:
	var enemy := main.zombie_scene.instantiate()
	enemy.global_position = marker.global_position
	main.Ysort.add_child(enemy)
