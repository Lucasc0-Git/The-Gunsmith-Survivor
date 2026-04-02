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
var _inv_tween: Tween

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
	if _inv_tween: _inv_tween.kill()
	if inventory.visible == true: #If is the inventory visible, turn it invible
		inv_toggled.emit(false)
		_inv_tween = create_tween()
		_inv_tween.set_ease(Tween.EASE_IN)
		_inv_tween.set_trans(Tween.TRANS_BACK)
		_inv_tween.tween_property(inventory, "global_position", Vector2(467, -540), 0.35)
		await _inv_tween.finished
		inventory.visible = false
	else: #If is the inventory invisible, turn it visible
		inv_toggled.emit(true)
		inventory.visible = true
		_inv_tween = create_tween()
		_inv_tween.set_ease(Tween.EASE_OUT)
		_inv_tween.set_trans(Tween.TRANS_BACK)
		_inv_tween.tween_property(inventory, "global_position", Vector2(467, 110), 0.35)

func tint_hud(new_color: Color, duration: float) -> void:
	if new_color == canvas_modulate.color: return
	var tween := create_tween()
	tween.tween_property(canvas_modulate, "color", new_color, duration)

func _input(event: InputEvent) -> void:
	## Calls toggle_inv() on "E" pressed
	if event.is_action_pressed("toggle_inventory"):
		toggle_inv()

func _on_hotbar_mouse_entered() -> void:
	toggle_hovering(true)
func _on_hotbar_mouse_exited() -> void:
	toggle_hovering(false)

func _on_basic_crafting_mouse_entered() -> void:
	toggle_hovering(true)
func _on_basic_crafting_mouse_exited() -> void:
	toggle_hovering(false)

func _on_weapons_crafting_container_mouse_entered() -> void:
	toggle_hovering(true)
func _on_weapons_crafting_container_mouse_exited() -> void:
	toggle_hovering(false)

func _on_tools_crafting_container_2_mouse_entered() -> void:
	toggle_hovering(true)
func _on_tools_crafting_container_2_mouse_exited() -> void:
	toggle_hovering(false)

func _on_crafting_stations_crafting_container_3_mouse_entered() -> void:
	toggle_hovering(true)
func _on_crafting_stations_crafting_container_3_mouse_exited() -> void:
	toggle_hovering(false)

func _on_base_crafting_container_3_mouse_entered() -> void:
	toggle_hovering(true)
func _on_base_crafting_container_3_mouse_exited() -> void:
	toggle_hovering(false)

func toggle_hovering(hovering_on: bool) -> void:
	weapon.hovering = hovering_on
