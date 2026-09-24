extends CanvasLayer

@export var mouse_right_click_icon_offset: Vector2 = Vector2(0, 0)

var hovered_right_clickable: Node = null

@onready var mouse_right_click_icon: TextureRect = %MouseRightClickIcon

func _ready() -> void:
	mouse_right_click_icon.hide()
	get_tree().node_added.connect(_on_node_added)

func _on_node_added(node: Node) -> void:
	if node is Slot:
		node.mouse_entered.connect(func() -> void: hovered_right_clickable = node)
		node.mouse_exited.connect(
			func() -> void:
				if hovered_right_clickable == node:
					hovered_right_clickable = null
		)
	elif node is BuildScene:
		node.mouse_input.mouse_entered.connect(func() -> void: if not node.preview_only: hovered_right_clickable = node)
		node.mouse_input.mouse_exited.connect(
			func() -> void:
				if not node.preview_only:
					if hovered_right_clickable == node:
						hovered_right_clickable = null
		)

func _process(_delta: float) -> void:
	mouse_right_click_icon.global_position = get_viewport().get_mouse_position() + mouse_right_click_icon_offset
	
	if hovered_right_clickable is Slot:
		if not hovered_right_clickable.slot_data or hovered_right_clickable.slot_data.is_empty():
			return
	
	if hovered_right_clickable != null:
		mouse_right_click_icon.show()
	else:
		mouse_right_click_icon.hide()
