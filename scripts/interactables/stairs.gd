extends Node

# Nodes
@onready var player: CharacterBody2D = $"../Player"
@onready var crt_animation: AnimationPlayer = $"../UI/CRT/AnimationPlayer"
@onready var timer_fade: Timer = $"../UI/CRT/TimerFade"

# Variables
var scene_type: String = ""
const FADE_DURATION: float = 1.0
const LEVEL_PATH_PREFIX: String = "res://scenes/levels/level_"
const LEVEL_PATH_SUFFIX: String = ".tscn"

func _ready() -> void:
	var timeout_callable = Callable(self, "_on_timer_timeout")
	if not timer_fade.is_connected("timeout", timeout_callable):
		timer_fade.connect("timeout", timeout_callable)

func new_scene() -> void:
	crt_animation.play("brightness_fade_in")
	timer_fade.start()
	scene_type = "new"
	# Game lock (player actions (interact and movement), enemies, etc...)
	# Clear enemies died on Gamemanager
	

func old_scene() -> void:
	crt_animation.play("brightness_fade_in")
	timer_fade.start()
	scene_type = "old"
	# Game lock (player actions (interact and movement), enemies, etc...)
	# Clear enemies died on Gamemanager

func _get_level_path(level_number: int) -> String:
	return LEVEL_PATH_PREFIX + str(level_number) + LEVEL_PATH_SUFFIX

func _on_timer_timeout() -> void:
	if scene_type == "new":
		GameManager.current_level += 1
	elif scene_type == "old":
		GameManager.current_level -= 1
		GameManager.player_going_to_old_scene = true
	var scene_path = _get_level_path(GameManager.current_level)
	get_tree().change_scene_to_file(scene_path)
