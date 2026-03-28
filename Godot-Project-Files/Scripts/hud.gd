extends CanvasLayer
class_name Hud
## The hud, handles progressbars (health), inventory

@onready var ui : UiBars = $UI
@onready var inventory : Inventory = $InventoryUI/Inventory
@onready var hotbar : Hotbar = $InventoryUI/Hotbar
@onready var player : Player
@onready var weapon : Weapon
@onready var tooltip: Tooltip = $Tooltip
@onready var canvas_modulate: CanvasModulate = $CanvasModulate
@onready var basic_crafting: BasicCraftingUI = $InventoryUI/BasicCrafting

## The @onready var declaration
@onready var hotbar_grid_container: GridContainer = $InventoryUI/Hotbar/PanelContainer/GridContainer

## The basic var declaration
var glock_item : ItemData
var shotgun_item : ItemData

## The signals declaration
signal inv_toggled(visible: bool)

## Set the player var by Main.gd script
func set_player(p: Player) -> void:
	player = p
	# connect hotbar signals to player
	# when a slot changes in UI, tell player to set hotbar item
	hotbar.slot_item_changed.connect(
		func(index: int, slot_data: SlotData) -> void:
			player.set_hotbar_item(index, slot_data)
	)
	# when slot selected (visual) -> update player current index
	hotbar.slot_selected.connect(
		func(index: int) -> void:
			player.on_hotbar_selected_by_ui(index)
	)
	
	weapon = player.weapon
	#hotbar.mouse_entered.connect(func() -> void: weapon.hovering = true; print("smthng"))
	#hotbar.mouse_exited.connect(func() -> void: weapon.hovering = false)
	
	
	# Set vars.
	tooltip.inventory = inventory
	hotbar.sync_from_player()
	inventory.player = player
	inventory.tooltip = tooltip
	inventory.hud = self
	inventory.basic_crafting = basic_crafting
	basic_crafting.inventory = inventory
	

# Called when "E" is just pressed
func toggle_inv() -> void:
	if inventory.visible == true: #If is the inventory visible, turn it invible
		inventory.visible = false
		inv_toggled.emit(false)
	else: #If is the inventory invisible, turn it visible
		inventory.visible = true
		inv_toggled.emit(true)

func tint_hud(new_color: Color, duration: float) -> void:
	if new_color == canvas_modulate.color: return
	var tween := create_tween()
	tween.tween_property(canvas_modulate, "color", new_color, duration)

func _input(event: InputEvent) -> void:
	## Calls toggle_inv() on "E" pressed
	if event.is_action_pressed("toggle_inventory"):
		toggle_inv()

func _on_hotbar_mouse_entered() -> void:
	weapon.hovering = true
	print("entered")

func _on_hotbar_mouse_exited() -> void:
	weapon.hovering = false
	print("exit")
