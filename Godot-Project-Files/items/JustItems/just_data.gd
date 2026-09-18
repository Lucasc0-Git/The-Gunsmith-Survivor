extends Resource
class_name JustData

##Data used fo holding the item in hands.
@export var id: String
@export var icon: Texture2D

@export_range(0.1, 10.0, 0.1) var rarity: float = 1.0 ## Bigger values will add less items to needed items for upgrade.
@export var rotatable: bool = false
