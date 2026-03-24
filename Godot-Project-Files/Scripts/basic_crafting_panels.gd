extends Control
class_name BasicCraftingUIPanel

@onready var weapons_crafting_container: PanelContainer = $VBoxContainer/Control/WeaponsCraftingContainer
@onready var tools_crafting_container: PanelContainer = $VBoxContainer/Control2/ToolsCraftingContainer2
@onready var stations_crafting_container: PanelContainer = $VBoxContainer/Control3/CraftingStationsCraftingContainer3

func _ready() -> void:
	weapons_crafting_container.visible = false
	tools_crafting_container.visible = false
	stations_crafting_container.visible = false

func toggle_weapons_crafting(_visible: bool) -> void:
	weapons_crafting_container.visible = _visible

func toggle_tools_crafting(_visible: bool) -> void:
	tools_crafting_container.visible = _visible

func toggle_stations_crafting(_visible: bool) -> void:
	stations_crafting_container.visible = _visible
