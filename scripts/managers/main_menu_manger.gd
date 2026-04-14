extends Control

# Nodes
@onready var timer_fade: Timer = $CanvasLayer/CRT/TimerFade
@onready var crt_animation: AnimationPlayer = $CanvasLayer/CRT/AnimationPlayer
@onready var option_buttons: VBoxContainer = $OptionButtons
@onready var menu_buttons: VBoxContainer = $MenuButtons

# Variables
@onready var buttons: Array[Button] = [] # TODO: Could be optimized
var button_type: String

func _ready() -> void:
	# Connect timer timeout signal
	var timeout_callable = Callable(self, "_on_timer_timeout")
	if not timer_fade.is_connected("timeout", timeout_callable):
		timer_fade.connect("timeout", timeout_callable)
	# Button focus
	for node in get_tree().get_nodes_in_group("ui_button"):
		if node is Button:
			buttons.append(node as Button)
	buttons[0].grab_focus()


### Menu Buttons
func _on_new_game_button_pressed() -> void:
	crt_animation.play("brightness_fade_in")
	timer_fade.start()
	button_type = "new_game"

func _on_load_game_button_pressed() -> void:
	pass
	#timer.start()
	#crt_animation.play("brightness_fade_in")
	#button_type = "load_game"

func _on_option_button_pressed() -> void:
	crt_animation.play("brightness_fade_in")
	timer_fade.start()
	button_type = "options"

func _on_quit_button_pressed() -> void:
	get_tree().quit()

## Option Buttons
func _on_exit_options_button_pressed() -> void:
	crt_animation.play("brightness_fade_in")
	timer_fade.start()
	button_type = "exit_options"


func _on_timer_timeout() -> void:
	match button_type:
		"new_game":
			get_tree().change_scene_to_file("res://scenes/levels/level_1.tscn")
			GameManager.current_level = 1
		"load_game":
			pass # TODO: make a save manager
		"options":
			crt_animation.play("brightness_fade_out")
			button_type = "none"
			buttons[4].grab_focus()
			option_buttons.visible = true
			menu_buttons.visible = false
		"exit_options":
			crt_animation.play("brightness_fade_out")
			button_type = "none"
			buttons[0].grab_focus()
			option_buttons.visible = false
			menu_buttons.visible = true
