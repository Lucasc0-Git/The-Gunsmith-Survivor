extends Resource
class_name InteractableData


@export var id: String = ""
@export var icon: Texture2D
@export var required_class: StringName = &""
@export var time_of_use: float = 0.0
@export var custom_stats: Dictionary = {} # {"repair": 20}
@export var consume_on_use: bool = true

@export var rotatable: bool = false ##If the item rotates in the direction of the mouse.
