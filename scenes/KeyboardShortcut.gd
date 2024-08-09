extends Node2D
class_name KeyboardShortcut

@onready var label = $Control/MarginContainer/MarginContainer/Label
@onready var animation_player = $AnimationPlayer

@export var shortcut: String
@export var fall_speed := 100

signal on_matched(value: String)
signal on_missed(value: String)

@onready var y_limit = get_viewport_rect().size.y + 50

var dead = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	label.text = shortcut
	add_to_group("shortcuts")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	global_position.y += fall_speed * delta 
	if global_position.y > y_limit and !dead:
		dead = true
		on_missed.emit(shortcut)
		$Oops.pitch_scale += randf_range(-0.2, 0.2)
		$Oops.play()
		$Oops.finished.connect(queue_free)

func is_match(value: String) -> bool:
	return value == shortcut

func matched() -> void:
	on_matched.emit(shortcut)
	$AnimationPlayer.play("score")
