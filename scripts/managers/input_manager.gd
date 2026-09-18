class_name InputManager extends Node

# Signals
signal move_input(direction: float)
signal run_input(pressed: bool)
signal interact_input(pressed: bool)

# Nodes
@onready var animation_manager: AnimationManager = %AnimationManager

# Variables
var input_enabled = true
var move_dir: float = 0.0
var run_pressed: bool = false
var interact_pressed: bool = false

func _ready() -> void:
	animation_manager.fade_in_started.connect(_disable_input)
	animation_manager.fade_out_ended.connect(_enable_input)

func _process(_delta: float) -> void:
	var new_move_dir = Input.get_axis("move_left", "move_right")
	var new_run_pressed = Input.is_action_pressed("run") and new_move_dir != 0
	var new_interact_pressed = Input.is_action_just_pressed("interact")
	if input_enabled:
		if new_move_dir != move_dir:
			move_dir = new_move_dir
			move_input.emit(move_dir)
		if new_run_pressed != run_pressed:
			run_pressed = new_run_pressed
			run_input.emit(run_pressed)
		if new_interact_pressed != interact_pressed:
			interact_pressed = new_interact_pressed
			interact_input.emit(interact_pressed)

func _disable_input() -> void:
	input_enabled = false
	if move_dir != 0.0:
		move_dir = 0.0
		move_input.emit(0.0)
	if run_pressed:
		run_pressed = false
		run_input.emit(false)

func _enable_input() -> void:
	input_enabled = true
