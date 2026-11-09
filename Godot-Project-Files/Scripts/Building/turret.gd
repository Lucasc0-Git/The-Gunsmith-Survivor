@tool
extends BuildScene
class_name Turret

# Export
@export var self_damage_per_second: float = 1.0

@export var turret_modulate: Color = Color(1, 1, 1)
@export var turret_damage: float = 0.0
@export var turret_range: float = 100
@export var turret_shoot_cooldown: float = 0.5

@export var bullet_scene: PackedScene
@export var bullet_speed_multiplier: float = 1.0
@export var bullet_scale: float = 1.0

@export var rotation_speed: float = 45 ##In degrees per second


# Onready
@onready var barrel_sprite: AnimatedSprite2D = %Barrel
@onready var muzzle: Marker2D = %Muzzle
@onready var reload_timer: Timer = %ReloadTimer

# Simple var
var can_shoot: bool = true
var target_acquired: bool = false
var target: Node2D = null
var target_rotation: float = 0.0

func _ready() -> void:
	super()
	if !Engine.is_editor_hint():
		sprite.modulate = turret_modulate
		barrel_sprite.modulate = turret_modulate

func _process(_delta: float) -> void:
	super(_delta)
	if sprite.modulate != turret_modulate or barrel_sprite.modulate != turret_modulate:
		sprite.modulate = turret_modulate
		barrel_sprite.modulate = turret_modulate
	if preview_only:
		return
	
	if is_instance_valid(target):
		_update_target_rotation()
		var desired := target_rotation - deg_to_rad(45)
		
		barrel_sprite.rotation = rotate_toward(
			barrel_sprite.rotation,
			desired, 
			deg_to_rad(rotation_speed) * _delta
		)
		target_acquired = abs(angle_difference(barrel_sprite.rotation, desired)) <= deg_to_rad(10)
		
		if target_acquired:
			shoot()
	else:
		barrel_sprite.rotation = rotate_toward(
			barrel_sprite.rotation,
			barrel_sprite.rotation + deg_to_rad(45),
			deg_to_rad(rotation_speed) * _delta
		)
		target_acquired = false

func _update_target_rotation() -> void:
	if not target: return 
	target_rotation = (target.global_position - global_position).angle()

func _update_target() -> Node:
	var best_target: Node = null
	
	var enemy_data: Array[Dictionary] = []
	
	for enemy: Node in get_tree().get_nodes_in_group("enemy"):
		if enemy is Enemy:
			var dist_sq: float = global_position.distance_squared_to(enemy.global_position)
			var d: Dictionary = {}
			d["node"] = enemy
			d["dist_sq"] = dist_sq
			enemy_data.append(d)
	
	if enemy_data == []: return null
	
	enemy_data.sort_custom(func(a: Variant, b: Variant) -> bool: return a["dist_sq"] < b["dist_sq"])
	
	var closest_enemy: Node = enemy_data[0].get("node", null)
	
	# Here i can add something more to choose the best target
	if closest_enemy and global_position.distance_squared_to(closest_enemy.global_position) <= (turret_range * turret_range):
		best_target = closest_enemy
	else:
		best_target = null
	
	return best_target

func shoot() -> void:
	if can_shoot:
		if _shoot():
			can_shoot = false
			reload_timer.start(turret_shoot_cooldown)

func _shoot() -> bool:
	if not bullet_scene: return false
	var bullet: Node2D = bullet_scene.instantiate()
	bullet.bullet_damage = turret_damage
	bullet.bullet_speed_multiplier = bullet_speed_multiplier
	bullet.scale *= bullet_scale
	get_tree().current_scene.add_child(bullet)
	bullet.global_position = muzzle.global_position
	bullet.rotation = barrel_sprite.rotation
	bullet.direction = Vector2.DOWN.rotated(barrel_sprite.rotation - deg_to_rad(45))
	return true

func _on_reload_timer_timeout() -> void:
	can_shoot = true

func _on_target_checking_timer_timeout() -> void:
	if preview_only: return
	if is_instance_valid(target):
		if global_position.distance_squared_to(target.global_position) > (turret_range * turret_range):
			target = null
			return
	target = _update_target()

func _on_self_damage_timer_timeout() -> void:
	health -= self_damage_per_second
	
	if health <= 0:
		destroy()
