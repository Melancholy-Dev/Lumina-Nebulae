extends Control

# Nodes
@onready var timer_fade: Timer = $CanvasLayer/CRT/TimerFade
@onready var crt_animation: AnimationPlayer = $CanvasLayer/CRT/AnimationPlayer
@onready var option_buttons: VBoxContainer = $OptionButtons
@onready var menu_buttons: VBoxContainer = $MenuButtons
@onready var menu_focus: AudioStreamPlayer = $AudioStreamPlayer/MenuFocus
@onready var menu_select: AudioStreamPlayer = $AudioStreamPlayer/MenuSelect

# Variables
@onready var buttons: Array[Button] = [] # TODO: Could be optimized
var button_type: String

# Focus sound control
var _allow_focus_sounds: bool = false
var _last_focused: Control = null

func _ready() -> void:
	# Connect timer timeout signal
	var timeout_callable = Callable(self, "_on_timer_timeout")
	if not timer_fade.is_connected("timeout", timeout_callable):
		timer_fade.connect("timeout", timeout_callable)
	# Buttons management
	for node in get_tree().get_nodes_in_group("ui_button"):
		if node is Button:
			var b := node as Button
			buttons.append(b)
	if buttons.size() > 0:
		buttons[0].grab_focus()
	_last_focused = get_viewport().gui_get_focus_owner()
	call_deferred("_enable_focus_sounds")

func _enable_focus_sounds() -> void:
	_allow_focus_sounds = true

## Sounds
func _on_button_focus_entered() -> void:
	var button = get_viewport().gui_get_focus_owner()
	if not _allow_focus_sounds:
		return
	if button == _last_focused:
		return
	_last_focused = button
	if menu_focus.playing:
		menu_focus.stop()
	menu_focus.play()

### Menu Buttons pressed
func _on_new_game_button_pressed() -> void:
	menu_select.play()
	crt_animation.play("brightness_fade_in")
	timer_fade.start()
	button_type = "new_game"

func _on_load_game_button_pressed() -> void:
	menu_select.play()
	#timer.start()
	#crt_animation.play("brightness_fade_in")
	#button_type = "load_game"

func _on_option_button_pressed() -> void:
	menu_select.play()
	crt_animation.play("brightness_fade_in")
	timer_fade.start()
	button_type = "options"

func _on_quit_button_pressed() -> void:
	menu_select.play()
	get_tree().quit()

## Option Buttons
func _on_exit_options_button_pressed() -> void:
	menu_select.play()
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
