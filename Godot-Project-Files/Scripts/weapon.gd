extends Node2D
class_name Weapon

## The onready var declaration
@onready var muzzle := $Muzzle
@onready var sprite := $Sprite2D
@onready var reload_timer := $ReloadTimer
@onready var player : Player
@onready var bang_particles: CPUParticles2D = $Muzzle/BangParticles

## The signal declaration
signal has_shot(rotation: float, recoil: float)

## The basic var declaration
var weapon_data: WeaponData
var can_shoot := true
var shooting := false
var shoot_on : bool = true
var bullet_damage : float
var hud : Hud
var equipped_item: SlotData = null

func _ready() -> void:
	await get_tree().physics_frame
	hud.inv_toggled.connect(inv_toggled)

func _input(event: InputEvent) -> void:
	## Handle the shoot input
	if event.is_action_pressed("shoot"):
		shooting = true
	elif event.is_action_released("shoot"):
		shooting = false

func equip_item(slot_data: SlotData) -> void:
	unequip()
	equipped_item = slot_data
	var item: ItemData = equipped_item.item_data
	sprite.visible = true
	if item is WeaponItemData:
		var w := item as WeaponItemData
		weapon_data = w.weapon_data
		sprite.texture = weapon_data.icon
		muzzle.position = weapon_data.muzzle_offset
		can_shoot = reload_timer.time_left <= 0
	elif item is HealItemData:
		var h := item as HealItemData
		sprite.texture = h.heal_data.icon
		can_shoot = true
	elif item is JustItemData:
		var j := item as JustItemData
		sprite.texture = j.just_data.icon
		can_shoot = true

func is_holding_weapon() -> bool:
	return true if equipped_item.item_data is WeaponItemData else false

## Unequip the item
func unequip() -> void:
	equipped_item = null
	weapon_data = null
	sprite.texture = null
	sprite.visible = false
	shooting = false
	can_shoot = false
	reload_timer.stop()
	bang_particles.emitting = false

func use_item(slot_data: SlotData) -> void:
	equipped_item = slot_data
	if !equipped_item: return
	## If equipped item is a weapon, use it correctly
	if equipped_item.item_data is WeaponItemData:
		_shoot_weapon()
	## If equipped item is a heal, use it correctly
	elif equipped_item.item_data is HealItemData:
		_use_heal_item()
		if equipped_item.amount <= 0:
			unequip()
	## If equipped item is a "just", dont use it
	elif equipped_item.item_data is JustItemData:
		pass
		
		
		if equipped_item.amount <= 0:
			unequip()

func _shoot_weapon() -> void:
	bang_particles.emitting = true ##One shot emit.
	can_shoot = false
	for i in weapon_data.pellets:
		_spawn_bullet(i)
	has_shot.emit(rotation, weapon_data.recoil)
	reload_timer.start(weapon_data.fire_rate)

func _use_heal_item() -> void:
	var heal_item := equipped_item.item_data as HealItemData
	var data := heal_item.heal_data
	## Heal player by the [heal] amount
	player.heal(data.heal)

## Spawn bullet on position with direction
func _spawn_bullet(i : int) -> void:
	var bullet := weapon_data.bullet_scene.instantiate()
	bullet.shrinking_rate = weapon_data.bullet_shrinking
	bullet.scale = weapon_data.bullet_scale * bullet.scale
	bullet_damage = weapon_data.damage
	get_tree().current_scene.add_child(bullet)
	## Position of the bullet
	bullet.global_position = muzzle.global_position
	# základní směr podle Weapon node
	var base_angle := rotation + deg_to_rad(45)
	var final_angle := base_angle
	
	if weapon_data.pellets > 1:
		var spread := weapon_data.spread
		var pellets := weapon_data.pellets
		# spread rovnoměrně od -spread/2 do +spread/2
		var start_angle := -spread / 2
		var step : float = spread / max(pellets - 1, 1)
		final_angle = base_angle + start_angle + step * i
	
	bullet.bullet_damage = bullet_damage
	bullet.rotation = final_angle
	bullet.direction = Vector2.RIGHT.rotated(final_angle)

func _on_reload_timer_timeout() -> void:
	can_shoot = true

func inv_toggled(inv_visible: bool) -> void:
	if inv_visible == true:
		shoot_on = false
	else:
		shoot_on = true

func _process(_delta: float) -> void:
	if equipped_item == null or equipped_item.is_empty():
		return
	if equipped_item and equipped_item.item_data.has_method("is_rotatable") and equipped_item.item_data.is_rotatable():
		var mouse_dir := get_global_mouse_position() - global_position
		scale = Vector2(1, 1)
		rotation = mouse_dir.angle() - deg_to_rad(45)
	else:
		#if player.last_dir == Vector2.LEFT:
			#rotation = -deg_to_rad(45) + deg_to_rad(180)
		#elif player.last_dir == Vector2.RIGHT:
			#rotation = -deg_to_rad(45)
		match player.last_dir:
			Vector2.LEFT:
				rotation = -deg_to_rad(45) + deg_to_rad(180)
			Vector2.RIGHT:
				rotation = -deg_to_rad(45)
			Vector2.UP:
				rotation = -deg_to_rad(45) - deg_to_rad(90)
			Vector2.DOWN:
				rotation = -deg_to_rad(45) + deg_to_rad(90)
		scale = Vector2(0.7, 0.7)
	## Shoot if its supposed to shoot
	if shooting and can_shoot and shoot_on:
		player.use_selected_item()
