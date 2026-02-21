extends CanvasLayer
class_name Hud
## The hud, handles progressbars (health), inventory

@onready var ui : UiBars = $UI
@onready var inventory : Inventory = $InventoryUI/Inventory
@onready var hotbar : Hotbar = $InventoryUI/Hotbar
@onready var player : Player
@onready var weapon : Weapon
@onready var tooltip: Tooltip = $Tooltip

## The @onready var declaration
@onready var hotbar_grid_container: GridContainer = $InventoryUI/Hotbar/PanelContainer/GridContainer

## The basic var declaration
var glock_item : ItemData
var shotgun_item : ItemData

## The signals declaration
signal inv_toggled(visible: bool)

func _on_item_used(item: ItemData) -> void:
	if item is WeaponItemData:
		var weapon_item := item as WeaponItemData
		emit_signal("weapon_selected", weapon_item.weapon_data)

## Set the player var by Main.gd script
func set_player(p: Player) -> void:
	player = p
	# connect hotbar signals to player
	# when a slot changes in UI, tell player to set hotbar item
	hotbar.slot_item_changed.connect(
		func(index: int, item: ItemData) -> void:
			player.set_hotbar_item(index, item)
	)
	# when slot selected (visual) -> update player current index
	hotbar.slot_selected.connect(
		func(index: int) -> void:
			player.on_hotbar_selected_by_ui(index)
	)
	
	# Set vars.
	tooltip.inventory = inventory
	hotbar.hud = self
	hotbar.sync_from_player()
	inventory.player = player
	inventory.tooltip = tooltip
	inventory.hud = self

# Called when "E" is just pressed
func toggle_inv() -> void:
	if inventory.visible == true: #If is the inventory visible, turn it invible
		inventory.visible = false
		inv_toggled.emit(false)
	else: #If is the inventory invisible, turn it visible
		inventory.visible = true
		inv_toggled.emit(true)

func _input(event: InputEvent) -> void:
	## Calls toggle_inv() on "E" pressed
	if event.is_action_pressed("toggle_inventory"):
		toggle_inv()
