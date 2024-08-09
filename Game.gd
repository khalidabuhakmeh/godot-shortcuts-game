extends Node2D

var shortcut_scene: PackedScene = preload("res://KeyboardShortcut.tscn")

@export var buffer_timeout := 0.500
@export var spawn_point_speed := 25

@onready var spawner: PathFollow2D = $CanvasLayer/Spawner/PathFollow2D
@onready var spawn_point: Node2D = $CanvasLayer/Spawner/PathFollow2D/Sprite2D
@onready var timer := $CanvasLayer/Timer
@onready var shortcut_group := $CanvasLayer/Shortcuts
@onready var score_display := $CanvasLayer/Control/MarginContainer/HBoxContainer/Score

var score := 0

var shortcuts := [
	"Shift Shift",
	"Ctrl+Enter",
	"Command+Enter",
	"Command+T",
	"Ctrl+T",
	"Ctrl Ctrl",
	"Ctrl+K Ctrl+C",
	"Option+Enter",
	"Enter",
	"Command+Right",
	"Command+Left",
	"Command+Up",
	"Command+Down"
]

var buffer: String
var time_elapsed_between_presses := 0.0
signal shortcut_matched(shortcut: String)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	shortcut_matched.connect(on_match)
	timer.timeout.connect(spawn_new_shortcut)
	$"Background Music".play()

func on_match(shortcut: String) -> void:
	var current_shortcuts = shortcut_group.get_children()
	for s: KeyboardShortcut in current_shortcuts:
		if s.is_match(shortcut):
			s.matched()
			break
	
func spawn_new_shortcut() -> void:
	var combo = shortcuts.pick_random()
	var instance: KeyboardShortcut = shortcut_scene.instantiate()
	instance.shortcut = combo
	instance.fall_speed += randi_range(-25, 75)
	instance.global_position = spawn_point.global_position
	instance.on_matched.connect(on_matched)
	instance.on_missed.connect(on_missed)
	shortcut_group.add_child(instance)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	time_elapsed_between_presses += delta
	spawner.progress += spawn_point_speed
	if time_elapsed_between_presses > buffer_timeout: _reset_buffer()

func _input(event: InputEvent) -> void:
	
	if event.is_action_pressed("ui_cancel"):
		# reset the game
		get_tree().reload_current_scene()
	
	if event is InputEventKey and event.is_pressed():
		$Press.play()
		var key_pressed = event.as_text_keycode()
		print("key pressed: ", key_pressed)
		buffer += " " + key_pressed
		buffer.trim_suffix(" ")
		time_elapsed_between_presses = 0.0
		
		var matched = func (shortcut: String): 
			return buffer.ends_with(shortcut)
			
		if shortcuts.any(matched):
			var shortcut = shortcuts.filter(matched)[0]
			_reset_buffer()
			shortcut_matched.emit(shortcut)

func _reset_buffer() -> void:
	buffer = ""
	time_elapsed_between_presses = 0.0
	
func on_matched(_value: String) -> void:
	score += 100
	score_display.text = str(score)

func on_missed(_value:String) -> void:
	score -= 50
	score_display.text = str(score)

