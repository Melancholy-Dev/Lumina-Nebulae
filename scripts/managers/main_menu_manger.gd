class_name MainMenu extends Control

# Signals
signal button_focus_entered
signal button_selected
signal new_menu_loaded
signal new_game_created
signal game_loaded

# Nodes
@export var game_version_label: Label
@export var menu_buttons: VBoxContainer
@export var option_buttons: VBoxContainer
@onready var animation_manager: AnimationManager = %AnimationManager
@onready var scene_manager: SceneManager = %SceneManager
@onready var buttons: Array[Button] = [] # TODO: Could be optimized

# Variables
var game_version: String = ProjectSettings.get_setting(
	"application/config/version",
	"0.0.0"
)
var button_type: String = ""
var _last_focused: Control = null

func _ready() -> void:
	# Set current version
	game_version_label.text = "v" + game_version + " - Melancholy"
	# Signals
	animation_manager.fade_in_ended.connect(_on_fade_in_ended)
	scene_manager.returned_to_main_menu.connect(_on_returned_to_main_menu)
	# Buttons management
	for node in get_tree().get_nodes_in_group("ui_button"):
		if node is Button:
			var b := node as Button
			buttons.append(b)
	if buttons.size() > 0:
		buttons[0].grab_focus()
	_last_focused = get_viewport().gui_get_focus_owner()

func _on_returned_to_main_menu() -> void:
	button_type = ""
	menu_buttons.visible = true
	option_buttons.visible = false
	if buttons.size() > 0:
		buttons[0].grab_focus()
	_last_focused = get_viewport().gui_get_focus_owner()

func _on_button_focus_entered() -> void:
	var button = get_viewport().gui_get_focus_owner()
	if button == _last_focused:
		return
	_last_focused = button
	button_focus_entered.emit()

### Menu Buttons pressed
func _on_new_game_button_pressed() -> void:
	button_selected.emit()
	button_type = "new_game"

func _on_load_game_button_pressed() -> void:
	button_selected.emit() # One save slot, checkpoint on each level, no extra menu
	button_type = "load_game"

func _on_option_button_pressed() -> void:
	button_selected.emit()
	button_type = "options"

func _on_quit_button_pressed() -> void:
	button_selected.emit()
	button_type = "quit"

# Option Buttons
func _on_exit_options_button_pressed() -> void:
	button_selected.emit()
	button_type = "exit_options"

func _on_fade_in_ended() -> void:
	var selected := button_type
	button_type = ""
	if selected.is_empty():
		return
	match selected:
		"new_game":
			new_game_created.emit()
		"load_game":
			game_loaded.emit()
			new_menu_loaded.emit() # Temporary
		"options":
			buttons[4].grab_focus()
			option_buttons.visible = true
			menu_buttons.visible = false
			new_menu_loaded.emit()
		"exit_options":
			buttons[0].grab_focus()
			option_buttons.visible = false
			menu_buttons.visible = true
			new_menu_loaded.emit()
		"quit":
			get_tree().quit()
		_:
			push_error("Button doesn't exist")
