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

@export var shoot_sound_volume: float = 0.0

# Onready
@onready var barrel_sprite: AnimatedSprite2D = %Barrel
@onready var muzzle: Marker2D = %Muzzle
@onready var reload_timer: Timer = %ReloadTimer
@onready var range_circle: Circle = $RangeCircle
@onready var turret_anim_player: AnimationPlayer = $TurretAnimPlayer

# Simple var
var can_shoot: bool = true
var target_acquired: bool = false
var target: Node2D = null
var target_rotation: float = 0.0

func _ready() -> void:
	super()
	if not Engine.is_editor_hint():
		var item_data: ItemData = get_item_data()
		if item_data is BuildItemData and item_data.build_data is TurretBuildData:
			var turret_build_data: TurretBuildData = item_data.build_data as TurretBuildData
			max_health = turret_build_data.max_health
			self_damage_per_second = turret_build_data.self_damage_per_second
			turret_modulate = turret_build_data.turret_modulate
			turret_damage = turret_build_data.turret_damage
			turret_range = turret_build_data.turret_range
			turret_shoot_cooldown = turret_build_data.turret_shoot_cooldown
			bullet_scene = turret_build_data.bullet_scene
			bullet_speed_multiplier = turret_build_data.bullet_speed_multiplier
			bullet_scale = turret_build_data.bullet_scale
			rotation_speed = turret_build_data.rotation_speed
			shoot_sound_volume = turret_build_data.shoot_sound_volume
		else:
			push_error("Turret data initialized unsuccessfully!")
		
		sprite.modulate = turret_modulate
		barrel_sprite.modulate = turret_modulate
		if is_instance_valid(range_circle):
			range_circle.radius = turret_range / 3
			range_circle.queue_redraw()
			range_circle.visible = true

func _process(_delta: float) -> void:
	if not GameManager or not "is_game_loaded" in GameManager:
		return
	if not GameManager.is_game_loaded: return
	super(_delta)
	if is_instance_valid(range_circle):
		if not range_circle.radius == turret_range / 3:
			range_circle.radius = turret_range / 3
			range_circle.queue_redraw()
	
	if sprite.modulate != turret_modulate or barrel_sprite.modulate != turret_modulate:
		sprite.modulate = turret_modulate
		barrel_sprite.modulate = turret_modulate
	if preview_only:
		if is_instance_valid(range_circle):
			range_circle.visible = true
		return
	else:
		var mouse_pos := get_global_mouse_position()
		if mouse_pos.distance_to(global_position) <= cursor_proximity_dist:
			if not anim_player.is_playing():
				if not range_circle.visible:
					turret_anim_player.play("show_range")
		else:
			if not anim_player.is_playing():
				if range_circle.visible:
					turret_anim_player.play("hide_range")
	
	
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
	if preview_only: return null
	
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
	if preview_only: return
	
	if can_shoot:
		if _shoot():
			AudioManager.play_sfx_2d("small_gun_shot", global_position, shoot_sound_volume)
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
	if preview_only: return
	can_shoot = true

func _on_target_checking_timer_timeout() -> void:
	if preview_only: return
	if is_instance_valid(target):
		if global_position.distance_squared_to(target.global_position) > (turret_range * turret_range):
			target = null
			return
	target = _update_target()

func _on_self_damage_timer_timeout() -> void:
	if preview_only: return
	health -= self_damage_per_second
	
	if health <= 0:
		destroy()
