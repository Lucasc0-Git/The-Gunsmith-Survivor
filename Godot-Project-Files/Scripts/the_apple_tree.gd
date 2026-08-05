extends TheTree
class_name TheAppleTree

@export var special_drop_item_data: ItemData
@export var growth_stage_duration: float = 90
@export var to_fruiting_duration: float = 60
@export var growth_duration_randomizer: float = 10
@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D

var starting_stage: Stages = Stages.SAPLING
var time_of_growth: float = 0
var growing: bool = false

enum Stages {
	SAPLING,
	YOUNG_TREE,
	SMALL_TREE,
	MATURE_TREE,
	FRUITING_TREE
}

func _ready() -> void:
	super()
	set_stage(starting_stage)
	set_time_of_growth()
	growing = true

func set_time_of_growth() -> void:
	time_of_growth = growth_stage_duration if get_stage() >= Stages.MATURE_TREE else to_fruiting_duration
	time_of_growth += randf_range(-growth_duration_randomizer / 2, growth_duration_randomizer * 1.5)

func _process(delta: float) -> void:
	super(delta)
	
	
	if growing:
		time_of_growth -= delta
		if time_of_growth <= 0:
			set_stage(get_stage() + 1)
			set_time_of_growth()
			if get_stage() >= Stages.FRUITING_TREE:
				growing = false

func set_stage(stage: Stages) -> void:
	animated_sprite.frame = stage

func get_stage() -> Stages:
	return animated_sprite.frame as Stages

func drop_special_items(amount: int, random_range: int) -> void:
	for i in range(amount):
		main.drop_item(special_drop_item_data, global_position, random_range)

func destroy() -> void:
	if get_stage() == Stages.FRUITING_TREE:
		drop_special_items(randi_range(0, 3), 40)
	super()
