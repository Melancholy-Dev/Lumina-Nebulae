extends Node

# Nodes
@onready var player: CharacterBody2D = $"../Player"
@onready var crt_animation: AnimationPlayer = $"../UI/CRT/AnimationPlayer"
@onready var timer: Timer = $"../UI/CRT/Timer"

# Variables
var scene_type: String = ""
const FADE_DURATION: float = 1.0
const LEVEL_PATH_PREFIX: String = "res://scenes/levels/level_"
const LEVEL_PATH_SUFFIX: String = ".tscn"

func _ready() -> void:
	var timeout_callable = Callable(self, "_on_timer_timeout")
	if not timer.is_connected("timeout", timeout_callable):
		timer.connect("timeout", timeout_callable)

func new_scene() -> void:
	crt_animation.play("brightness_fade_in")
	timer.start()
	scene_type = "new"
	#await get_tree().create_timer(FADE_DURATION).timeout
	# Game lock (player actions (interact and movement), enemies, etc...)
	# Clear enemies died on Gamemanager
	

func old_scene() -> void:
	crt_animation.play("brightness_fade_in")
	timer.start()
	scene_type = "old"
	#await get_tree().create_timer(FADE_DURATION).timeout
	# Game lock (player actions (interact and movement), enemies, etc...)
	# Clear enemies died on Gamemanager

func _get_level_path(level_number: int) -> String:
	return LEVEL_PATH_PREFIX + str(level_number) + LEVEL_PATH_SUFFIX

func _on_timer_timeout() -> void:
	if scene_type == "new":
		GameManager.current_level += 1
	elif scene_type == "old":
		GameManager.current_level -= 1
	var scene_path = _get_level_path(GameManager.current_level)
	get_tree().change_scene_to_file(scene_path)
	# Collego segnale timer
