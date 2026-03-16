extends Node
## Handle global things; autoload

var current_world_seed: int
var time: float = 0.0
var day_length: float = 600.0
var current_hour: int = 0
var current_day: int = 0

signal hour_changed(hour: int)
signal day_changed(day: int)

func _process(delta: float) -> void:
	if get_tree().paused: return
	time += delta
	
	var new_hour := int((time / day_length) * 24) % 24
	if new_hour != current_hour:
		current_hour = new_hour
		hour_changed.emit(current_hour)
	
	var new_day := int(time / day_length)
	if new_day != current_day:
		current_day = new_day
		day_changed.emit(current_day)

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("exit"):
		#get_tree().quit()
		pass


func set_hour(hour: int) -> void:
	# keep the current day, just change the hour
	var day_progress := float(hour) / 24.0
	time = current_day * day_length + day_progress * day_length
	current_hour = hour
	hour_changed.emit(current_hour)

func set_day(day: int) -> void:
	# keep the current hour, just change the day
	time = day * day_length + (float(current_hour) / 24.0) * day_length
	current_day = day
	day_changed.emit(current_day)
