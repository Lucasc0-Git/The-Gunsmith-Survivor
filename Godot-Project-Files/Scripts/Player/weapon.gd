extends Node2D
class_name Weapon

## The onready var declaration
@onready var muzzle := $Muzzle
@onready var sprite := $Sprite2D
@onready var reload_timer := $ReloadTimer
@onready var player : Player
@onready var bang_particles: CPUParticles2D = $Muzzle/BangParticles
@onready var bang_light: PointLight2D = $Muzzle/PointLight2D

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
var hovering: bool = false
var holding_build: bool = false
var build_preview: BuildScene
var can_place: bool = false

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
	if build_preview:
		build_preview.collision_shape.set_deferred("disabled", true)
		build_preview.visible = false
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
	elif item is BuildItemData:
		var b := item as BuildItemData
		sprite.texture = b.build_data.icon
		build_preview = item.build_data.build_scene.instantiate() #instantiate the build scene
		#build_preview.modulate = item.build_data.transparent_color #set transparency to 50
		build_preview.collision_shape.set_deferred("disabled", true)
		player.main.add_child(build_preview)
		holding_build = true
		can_shoot = true

func is_holding_usable_item() -> bool:
	return true if equipped_item.item_data is HealItemData or BuildItemData else false

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
	holding_build = false
	if build_preview:
		build_preview.visible = false
		build_preview.collision_shape.set_deferred("disabled", true)
		build_preview.queue_free()

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
		player.on_use_made()
	## If equipped item is a "just", dont use it
	elif equipped_item.item_data is JustItemData:
		pass
		if equipped_item.amount <= 0:
			unequip()
	elif equipped_item.item_data is BuildItemData:
		if can_place:
			_spawn_build()
			if equipped_item.amount <= 0:
				unequip()
			if build_preview.visible:
				player.on_use_made()

func _spawn_build() -> void:
	var build_item := equipped_item.item_data as BuildItemData
	player.main.spawn_building(get_global_mouse_position(), build_item.build_data.build_scene)

func _shoot_weapon() -> void:
	bang_particles.emitting = true ##One shot emit.
	can_shoot = false
	for i in weapon_data.pellets:
		_spawn_bullet(i)
	has_shot.emit(rotation, weapon_data.recoil)
	reload_timer.start(weapon_data.fire_rate)
	bang_light.enabled = true
	await get_tree().create_timer(0.05).timeout
	bang_light.enabled = false

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

func is_placement_valid() -> bool:
	var space_state := get_world_2d().direct_space_state
	var shape_query := PhysicsShapeQueryParameters2D.new()
	shape_query.shape = build_preview.collision_shape.shape
	shape_query.transform = build_preview.collision_shape.global_transform
	
	shape_query.collision_mask = 0b10001110 ##Works like: 0b+layer8(0=off, 1=on)+layer7+layer6+layer5+layer4+layer3+layer2+layer1
	
	shape_query.exclude = [build_preview.get_rid()]
	var results := space_state.intersect_shape(shape_query)
	return results.is_empty()

func _process(_delta: float) -> void:
	if equipped_item == null or equipped_item.is_empty():
		return
	if equipped_item and equipped_item.item_data.has_method("is_rotatable") and equipped_item.item_data.is_rotatable():
		var mouse_dir := get_global_mouse_position() - global_position
		scale = Vector2(1, 1)
		rotation = mouse_dir.angle() - deg_to_rad(45)
		# in weapon.gd _process()
		if get_global_mouse_position().y < player.global_position.y:
			pass   # mouse above = weapon behind sprite
		else:
			pass  # mouse below = weapon in front
	else:
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
		if player.last_dir.y >= 0:
			pass
		else:
			pass
	
	if holding_build:
		var mouse_pos := get_global_mouse_position()
		var distance := global_position.distance_to(mouse_pos)
		if distance <= player.build_reach:
			build_preview.visible = true
			build_preview.global_position = mouse_pos #update position of the preview to the mouse_pos
			var build_data: BuildItemData = equipped_item.item_data as BuildItemData
			if is_placement_valid():
				build_preview.sprite.modulate = build_data.build_data.transparent_color
				can_place = true
			else:
				build_preview.sprite.modulate = build_data.build_data.cant_build_color
				can_place = false
		else:
			build_preview.visible = false
			can_place = false
			#set build scene preview visible = false
		
	## Shoot if its supposed to shoot
	if shooting and can_shoot and shoot_on and !hovering:
		player.use_selected_item()
