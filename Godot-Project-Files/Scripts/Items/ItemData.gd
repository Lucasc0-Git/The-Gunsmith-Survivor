extends Resource
class_name ItemData

## Data for every item in the game
@export var id: String ##Unique name (like "glock", "shotgun").
@export var icon: Texture2D ##The texture of the item showed in inventory.
@export var display_name: String ##The name of the item for da player.
@export var stack_size : int = 1 ##Default stack.
@export var current_stack_size: int = 1
@export_range(0, 128) var max_stack: int = 1 ##Maximum stacking for the item.
@export var description : String = "" ##The description of the item used in tooltip.
@export var crafting_description: String = "" ##The description of the item used in crafting tooltip (tooltip of the crafting menu) [br][br]Note: if none, the description variable will be used
@export var crafting_recipe: Dictionary[ItemData, int] ={} ##All items needed to have in inventory to craft this item.
