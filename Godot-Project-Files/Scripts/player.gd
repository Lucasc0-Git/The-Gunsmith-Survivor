extends CharacterBody2D
class_name Player

## The basic vars declaration
var current_state: State
var states := {}
var target_speed: Vector2
var hotbar_slots: Array[ItemData] = [] ##Slots of the hotbar
var current_hotbar_index := 0 ##From which slot it equips item.
var last_dir: Vector2
var input_dir: Vector2 = Vector2.ZERO

## The @onready vars declaration
@onready var anim_player: AnimatedSprite2D = $AnimatedSprite2D
@onready var states_node := $StateMachine
@onready var weapon: Weapon = $Weapon
@onready var hud: Hud
@onready var inventory_ui: Control
@onready var spawn_pos := global_position

## The export vars declaration
@export var accel := 500.0
@export var speed: int = 200
@export var health_max := 100.0
@export var health_regen_rate: float = 5

## The signals declaration
signal health_update(current: float, maximum: float)

## The "exclusive" var declaration
var health : float = health_max:
	set(value):
		value = clamp(value, 0, health_max)
		if health == value: return
		health = value
		health_update.emit(health, health_max)

## Called on start; State machine
func _ready() -> void:
	##Connect signals
	weapon.has_shot.connect(apply_recoil)
	## Add starting weapons
	for i in range(5):
		hotbar_slots.append(null)
	## State machine
	for child in states_node.get_children():
		if child is State:
			states[child.name] = child
			child.player = self
	change_state("Idle")

## Set the player var by Main.gd script
func set_vars(h: Hud) -> void:
	hud = h
	inventory_ui = hud.get_node("InventoryUI")
	##Connect signals
	hud.hotbar.slot_selected.connect(_on_hotbar_slot_selected)
	##Set vars in other nodes
	weapon.player = self
	weapon.hud = hud
	hud.weapon = weapon

## State machine
func change_state(state_name: String) -> void:
	if current_state:
		current_state.exit()
	current_state = states[state_name]
	current_state.enter()

func _on_weapon_selected(data: WeaponData) -> void:
	weapon.equip(data)

func _on_hotbar_slot_selected(index: int) -> void:
	on_hotbar_selected_by_ui(index)

## In hotbar, set [item] on [index]
func set_hotbar_item(index: int, item: ItemData) -> void:
	if index < 0:
		return
	if index>= hotbar_slots.size():
		return
	hotbar_slots[index] = item
	## Update current weapon
	if index == current_hotbar_index:
		_update_equipped()

func on_hotbar_selected_by_ui(index: int) -> void:
	current_hotbar_index = index
	_update_equipped()

## Equip item, which has to be equipped, bc its in the current hotbar slot
func _update_equipped() -> void:
	## Declare item var
	var item: ItemData = null
	## Set [item] to whichever is in current hotbar slot
	if current_hotbar_index >= 0 and current_hotbar_index < hotbar_slots.size():
		item = hotbar_slots[current_hotbar_index]
	## If there is nothing to equip, call unequip()
	if item == null:
		weapon.unequip()
		return
	## Equip the item
	weapon.equip_item(item)

## Move the player by speed in get_input_dir() direction
func apply_movement(delta: float) -> void:
	target_speed = input_dir * speed
	velocity = velocity.move_toward(target_speed, accel * delta)

## Get [input_dir] for other scripts, like state machine	#Need that so i dont need to change a lot of code
func get_input_dir() -> Vector2:
	return input_dir

func _process(_delta: float) -> void:
	input_dir = Input.get_vector("move_left", "move_right", "move_up", "move_down")

## Called every physics frame
func _physics_process(delta: float) -> void:
	#For testing things (need to remove them!)
	if Input.is_action_just_pressed("hurt"):
		get_hurt(20)
	
	## Handle respawn
	if health <= 0:
		respawn()
	## Apply regeneration
	regen(delta)
	## Apply all movement for that physics frame
	apply_movement(delta)
	## Move CharacterBody2D by the [velocity]
	move_and_slide()
	## Update the physics in the state; State machine
	if current_state:
		current_state.physics_update(delta)

##Reset of everything (except the inventory), need to replace with something else on death
func respawn() -> void:
	global_position = spawn_pos
	health = health_max
	velocity = Vector2.ZERO

## Add health to current health by [amount]
func heal(amount: int) -> void:
	health += amount
 
## Remove health from current health by [amount]
func get_hurt(amount: float) -> void:
	health -= amount

## Add health to current health over time
func regen(delta: float) -> void:
	health += health_regen_rate * delta

## Select another slot in hotbar
func switch_weapon(dir: int, by_scrolling: bool) -> void:
	if by_scrolling:
		## Select hotbar slot neighbouring with current selected hotbar slot, [dir] is -1 or 1
		current_hotbar_index += dir
		if current_hotbar_index >= hotbar_slots.size():
			current_hotbar_index = 0
		elif current_hotbar_index < 0:
			current_hotbar_index = hotbar_slots.size() - 1
	else:
		## Select hotbar slot with INDEX [dir]
		current_hotbar_index = clamp(dir, 0, hotbar_slots.size() - 1)
	
	hud.hotbar.select_slot(current_hotbar_index)
	_update_equipped()

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("next_weapon"):
		switch_weapon(1, true)
	elif event.is_action_pressed("prev_weapon"):
		switch_weapon(-1, true)
	
	for i in range(1, 6):
		if event.is_action_pressed("slot_%d_hotbar" % i):
			switch_weapon(i - 1, false)

## Apply reversed velocity on shoot
func apply_recoil(weapon_rotation: float, recoil_strenght: float) -> void:
	var dir := Vector2.RIGHT.rotated(weapon_rotation + deg_to_rad(45))
	velocity -= dir * recoil_strenght
