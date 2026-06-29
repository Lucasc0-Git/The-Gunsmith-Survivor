extends Node2D
class_name Weapon

## The onready var declaration
@onready var muzzle := $Muzzle
@onready var sprite := $Sprite2D
@onready var reload_timer := $ReloadTimer
@onready var player : Player
@onready var bang_particles: CPUParticles2D = $Muzzle/BangParticles
@onready var bang_light: PointLight2D = $Muzzle/PointLight2D
@onready var hit_area: Area2D = $HitArea
@onready var hit_area_collision_shape: CollisionShape2D = $HitArea/CollisionShape2D
@onready var overheat_timer: Timer = $OverheatTimer
@onready var overheated_hissing: AudioStreamPlayer = $WeaponOverheatedHissing

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
var current_heat: float = 0.0
var is_overheated: bool = false
var heat_material: ShaderMaterial

func _ready() -> void:
	while  !GameManager.is_game_loaded:
		await get_tree().process_frame
	if !hud: push_error("Weapon: HUD is null!")
	if !player: push_error("Weapon: Player is null!")
	
	
	hud.inv_toggled.connect(inv_toggled)
	hit_area.monitoring = false

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
		build_preview.preview_only = true
		if build_preview is StationBuildScene:
			build_preview.crafting_area.monitoring = false
	
	if item is WeaponItemData:
		var w := item as WeaponItemData
		w.update_heat()
		weapon_data = w.weapon_data
		current_heat = w.current_heat
		
		sprite.texture = weapon_data.icon
		muzzle.position = weapon_data.muzzle_offset
		can_shoot = reload_timer.time_left <= 0
		if weapon_data.heated:
			if !heat_material:
				heat_material = ShaderMaterial.new()
				heat_material.shader = preload("res://Shaders/weapon_heat.gdshader")
			sprite.material = heat_material
	
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
		build_preview.preview_only = true
		player.main.call_deferred("add_child", build_preview)
		holding_build = true
		can_shoot = true
	
	elif item is CloseWeaponItemData:
		var c := item as CloseWeaponItemData
		sprite.texture = c.close_weapon_data.icon
		
		weapon_data = c.close_weapon_data
		
		can_shoot = reload_timer.time_left <= 0
	
	else:
		var i := item as ItemData
		if i.icon:
			sprite.texture = i.icon
		can_shoot = true

func is_holding_usable_item() -> bool:
	return true if equipped_item.item_data is HealItemData or BuildItemData else false

## Unequip the item
func unequip() -> void:
	if equipped_item and equipped_item.item_data is WeaponItemData:
		var w := equipped_item.item_data as WeaponItemData
		w.current_heat = current_heat
		w.last_cooled_time = Time.get_unix_time_from_system()
	
	if overheated_hissing.playing:
		overheated_hissing.stop()
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
		if build_preview is StationBuildScene:
			build_preview.crafting_area.monitoring = false
		build_preview.visible = false
		build_preview.collision_shape.set_deferred("disabled", true)
		build_preview.queue_free()
	current_heat = 0.0
	is_overheated = false

func use_item(slot_data: SlotData) -> void:
	equipped_item = slot_data
	if !equipped_item: return
	
	if equipped_item.item_data is CloseWeaponItemData:
		_swing_weapon()
	## If equipped item is a weapon, use it correctly
	elif equipped_item.item_data is WeaponItemData:
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
	## If equipped item is a buildable thing, try to build it at the cursor.
	elif equipped_item.item_data is BuildItemData:
		if can_place:
			_spawn_build()
			if equipped_item.amount <= 0:
				unequip()
			if build_preview.visible:
				player.on_use_made()

func _spawn_build() -> void:
	GameManager.more_stats["Buildings built"] += 1
	var build_item := equipped_item.item_data as BuildItemData
	player.main.spawn_building(get_global_mouse_position(), build_item.build_data.build_scene)

func _swing_weapon() -> void:
	var data: CloseWeaponItemData = equipped_item.item_data as CloseWeaponItemData
	var close_data: CloseWeaponData = data.close_weapon_data
	reload_timer.start(close_data.swing_duration + close_data.afterswing_time)
	can_shoot = false
	if !hit_area: push_error("HitArea is null!"); return
	
	
	var rect_shape: RectangleShape2D = hit_area_collision_shape.shape as RectangleShape2D
	if rect_shape:
		rect_shape.size = Vector2(close_data.dmg_range * 0.3, close_data.dmg_range)
		hit_area_collision_shape.position = Vector2(close_data.dmg_range * 0.5, close_data.dmg_range * 0.5)
	
	var original_rotation := rotation_degrees
	rotation_degrees -= (close_data.close_spread / 2)
	
	hit_area.monitoring = true
	var swing_tween: Tween = create_tween()
	swing_tween.set_trans(Tween.TRANS_QUAD)
	swing_tween.set_ease(Tween.EASE_OUT)
	swing_tween.tween_property(self, "rotation_degrees", original_rotation + (close_data.close_spread/2), close_data.swing_duration)
	await swing_tween.finished
	hit_area.monitoring = false

func _on_hit_area_body_entered(body: Node2D) -> void:
	if body.has_method("take_damage"):
		if !equipped_item.item_data is CloseWeaponItemData: return
		body.take_damage(
			equipped_item.item_data.close_weapon_data.damage, 
			equipped_item.item_data.close_weapon_data.dmg_type, 
			equipped_item.item_data.close_weapon_data.weapon_type
		)
		var data: CloseWeaponItemData = equipped_item.item_data as CloseWeaponItemData
		
		AudioManager.play_sfx_2d("bullet_landing", body.global_position)
		
		if body is CharacterBody2D:
			var dir := (body.global_position - player.global_position).normalized()
			body.velocity += dir * (data.close_weapon_data.knockback)

func _shoot_weapon() -> void:
	if !can_shoot or is_overheated:
		return
	
	AudioManager.play_sfx(weapon_data.use_sound, weapon_data.sound_added_volume)
	
	if weapon_data.heated:
		current_heat += weapon_data.heat_per_shot
		if current_heat >= weapon_data.max_heat:
			current_heat = weapon_data.max_heat
			is_overheated = true
			if !overheated_hissing.playing:
				overheated_hissing.play()
			#reload_timer.start(weapon_data.overheat_cooldown)
			#Visual: particles etc
			return
		if equipped_item and equipped_item.item_data is WeaponItemData:
			(equipped_item.item_data as WeaponItemData).current_heat = current_heat
	
	bang_particles.emitting = true ##One shot emit.
	can_shoot = false
	for i in weapon_data.pellets:
		_spawn_bullet(i)
	has_shot.emit(rotation, weapon_data.recoil)
	reload_timer.start(weapon_data.fire_rate)
	bang_light.enabled = true
	await get_tree().create_timer(0.05).timeout
	bang_light.enabled = false
	
	if weapon_data.weapon_type == "Shotgun":
		await get_tree().create_timer(0.2).timeout
		AudioManager.play("shotgun_reload")

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
	bullet.dmg_type = equipped_item.item_data.weapon_data.dmg_type
	bullet.weapon_type = equipped_item.item_data.weapon_data.weapon_type
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
	else:
		var spread := weapon_data.spread
		final_angle = base_angle + randf_range(-(spread/2), (spread/2))
	
	bullet.bullet_damage = bullet_damage
	bullet.rotation = final_angle
	bullet.direction = Vector2.RIGHT.rotated(final_angle)

func _on_reload_timer_timeout() -> void:
	can_shoot = true
	if is_overheated and current_heat <= weapon_data.max_heat / 2:
		is_overheated = false
		overheated_hissing.stop()

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

func _process(delta: float) -> void:
	if !GameManager.is_game_loaded: return
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
	
	if weapon_data:
		if weapon_data.heated and current_heat > 0:
			if current_heat >= weapon_data.max_heat:
				if !overheated_hissing.playing:
					overheated_hissing.play()
			else:
				if current_heat < weapon_data.max_heat / 1.75:
					overheated_hissing.stop()
			
			if !shooting:
				current_heat -= weapon_data.heat_conductivity * delta
			else:
				current_heat -= weapon_data.heat_conductivity * delta * 0.8
			
			current_heat = max(current_heat, 0.0)
			
			if is_overheated and current_heat <= weapon_data.max_heat / 2:
				is_overheated = false
				can_shoot = true
	
		if sprite.material is ShaderMaterial:
			sprite.material.set_shader_parameter("heat_amount", current_heat / weapon_data.max_heat)
	
	if holding_build:
		var mouse_pos := get_global_mouse_position()
		var distance := global_position.distance_to(mouse_pos)
		if distance <= player.build_reach:
			if build_preview is StationBuildScene:
				if build_preview.crafting_area.monitoring:
					build_preview.crafting_area.monitoring = false
			
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
