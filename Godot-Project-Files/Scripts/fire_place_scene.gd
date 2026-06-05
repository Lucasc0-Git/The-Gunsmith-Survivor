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
		
