extends Resource
class_name BuildData

@export var id: String
@export var icon: Texture2D
@export var build_scene: PackedScene
@export var transparent_color: Color = Color(1.0, 1.0, 1.0, 0.549)
@export var cant_build_color: Color = Color(1.0, 0.0, 0.0, 0.588)

@export var rotatable: bool = false
@export var is_light_source: bool = false
