extends Resource
class_name WeaponData

@export var id : String ##Name of the weapon for the code.
@export var icon : Texture2D ##The texture for the weapon, which the player holds (NOT texture in inventory).
@export var damage : int = 10 ##How much damage the weapon does.
@export var fire_rate : float = 0.25 ##How much time flows in between of two shots (in seconds).
@export var bullet_scene : PackedScene ##The scene of the bullet.
@export var bullet_shrinking: float = 0.98 ##How much each bullet shrinks over time. 1.0 means no shrinking, everything lower than 0.975 is useless.
@export var muzzle_offset : Vector2 = Vector2(10, 10) ##How much pixels is the weapon far from the player (both numbers the same).
@export var bullet_scale : Vector2 = Vector2(1.0, 1.0) ##The scale of the bullet for each weapon.
@export var recoil : float = 50 ##How much do player go backwards after shooting.
@export var rotatable: bool = true ##If the weapon can be rotated around the player.

@export var pellets : int = 1 ##The number of shots at the same time.
@export var spread : float = 0.0 ##How much inaccurate is the weapon, or, with more shots at the same time, it's for the spread of the shots.
