extends Resource
class_name HealData

##Data of heal items in the game used for HOLDING the item in hands. NOT in inventory.
@export var id: String = "" ##The name of the item.
@export var icon: Texture2D ##The texture, which the player holds. NOT the texture in inventory.
@export var description: String = "" ##Description of the item.
@export var heal: int = 20 ##The amount of health healed.
@export var over_time_heal: bool = false ##If true, the item will on use heal the "heal" amount of health over "time_healing" amount of time (seconds).
@export var time_healing: float = 3 ##Only if over_time_heal is true. Time in seconds, over which will be healed the amount of health.

@export var rotatable: bool = false ##If the item rotates in the direction of the mouse.
