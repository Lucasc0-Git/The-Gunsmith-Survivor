@tool
extends BuildScene
class_name FirePlaceScene


func _process(_delta: float) -> void:
	if not GameManager or not "is_game_loaded" in GameManager:
		return
	if !GameManager.is_game_loaded: return
	if preview_only:
		$MouseInputMonitor.monitoring = false
		$CPUParticles2D.emitting = false
	else:
		$MouseInputMonitor.monitoring = true
		$CPUParticles2D.emitting = true
		
	var mouse_pos: Vector2 = get_global_mouse_position()
	if preview_only: return
	if mouse_pos.distance_to(global_position) <= cursor_proximity_dist:
		if anim_player.is_playing():
			return
		if !health_bar.visible:
			anim_player.play("show_bar")
	else:
		if anim_player.is_playing():
			return
		if health_bar.visible:
			anim_player.play("hide_bar")
