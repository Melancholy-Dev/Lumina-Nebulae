extends Control

# Nodes
@onready var timer: Timer = $CanvasLayer/CRT/Timer
@onready var crt_animation: AnimationPlayer = $CanvasLayer/CRT/AnimationPlayer

# Variables
@onready var buttons: Array[Button] = [] # Could be optimized
var button_type: String

func _ready() -> void:
	for node in get_tree().get_nodes_in_group("ui_button"):
		if node is Button:
			buttons.append(node as Button)
	buttons[0].grab_focus()


### Buttons
func _on_new_game_button_pressed() -> void:
	button_type = "new_game"
	timer.start()
	crt_animation.play("brightness_fade_in")

func _on_load_game_button_pressed() -> void:
	pass
	#button_type = "load_game"
	#timer.start()
	#crt_animation.play("brightness_fade_in")

func _on_option_button_pressed() -> void:
	pass
	#button_type = "options"
	#timer.start()
	#crt_animation.play("brightness_fade_in")

func _on_quit_button_pressed() -> void:
	get_tree().quit()


func _on_timer_timeout() -> void:
	match button_type:
		"new_game":
			get_tree().change_scene_to_file("res://scenes/game.tscn")
		"load_game":
			pass # TODO: make a save manager
		"options":
			pass # TODO: make a option menu
