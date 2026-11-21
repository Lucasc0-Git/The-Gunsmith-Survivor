extends BuildData
class_name TurretBuildData

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

@export var max_health: float = 100.0
