extends Control
class_name TheCoreArrow

@onready var anim_player: AnimationPlayer = %AnimationPlayer

var main: Main
var the_core: TheCore
var player: Player

func _ready() -> void:
	visible = false

func _process(_delta: float) -> void:
	if not GameManager.is_game_loaded: return
	if not main: main = GameManager.main; return
	if not the_core: the_core = main.the_core; return
	if not player: player = main.player; return
	if not is_offscreen(): 
		visible = false
		return
	if not visible:
		modulate = Color(1, 1, 1, 0)
		visible = true
		play_anim("show")
	
	var core_pos: Vector2 = the_core.global_position
	var viewport: Viewport = get_viewport()
	var canvas_transform: Transform2D = viewport.get_canvas_transform()
	
	var screen_pos: Vector2 = canvas_transform * core_pos
	
	var viewport_size: Vector2 = viewport.get_visible_rect().size
	var margin: int = 5
	var rect: Rect2 = Rect2(Vector2(margin, margin), viewport_size - Vector2(margin * 2, margin * 2))
	
	var clamped: Vector2 = screen_pos.clamp(rect.position, rect.end)
	
	position = clamped
	
	var core_dir: Vector2 = (core_pos - main.player.global_position)
	var angle_to_core := core_dir.angle() + deg_to_rad(90)
	rotation = angle_to_core
	

func is_offscreen() -> bool:
	if not the_core: return false
	var viewport: Viewport = get_viewport()
	var canvas_transform: Transform2D = viewport.get_canvas_transform()
	var screen_pos: Vector2 = canvas_transform * the_core.global_position
	var viewport_rect: Rect2 = Rect2(Vector2.ZERO, viewport.get_visible_rect().size)
	
	return not viewport_rect.has_point(screen_pos)

func play_anim(anim: String) -> void:
	if anim_player.is_playing():
		anim_player.stop()
	anim_player.play(anim)
