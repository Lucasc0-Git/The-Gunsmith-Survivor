extends Resource
class_name ItemData

## Data for every item in the game
@export var id: String ##Unique name (like "glock", "shotgun").
@export var icon: Texture2D ##The texture of the item showed in inventory.
@export var display_name: String ##The name of the item for da player.
@export var stack_size : int = 1 ##Default stack.
@export var current_stack_size: int = 1
@export var max_stack: int = 1 ##Maximum stacking for the item.
@export var description : String = "" ##The description of the item used in tooltip.
