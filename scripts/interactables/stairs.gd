extends Node

# Nodes
@onready var player: CharacterBody2D = $"../Player"
@onready var next_player_position_up: Node2D = $NextPlayerPositionUp
@onready var next_player_position_down: Node2D = $NextPlayerPositionDown
@onready var crt_animation: AnimationPlayer = $"../UI/CRT/AnimationPlayer"

# Constants
const FADE_DURATION: float = 1.0
const LEVEL_PATH_PREFIX: String = "res://scenes/levels/level_"
const LEVEL_PATH_SUFFIX: String = ".tscn"

func go_up() -> void:
	crt_animation.play("brightness_fade_in")
	await get_tree().create_tween().tween_callback(func(): pass).finished
	await get_tree().create_timer(FADE_DURATION).timeout
	# Game lock (player actions (interact and movement), enemies, etc...)
	player.position = next_player_position_up.position
	crt_animation.play("brightness_fade_out")

func go_down() -> void:
	crt_animation.play("brightness_fade_in")
	await get_tree().create_timer(FADE_DURATION).timeout
	# Game lock (player actions (interact and movement), enemies, etc...)
	player.position = next_player_position_down.position
	crt_animation.play("brightness_fade_out")

func new_scene() -> void:
	crt_animation.play("brightness_fade_in")
	await get_tree().create_timer(FADE_DURATION).timeout
	# Game lock (player actions (interact and movement), enemies, etc...)
	GameManager.current_level += 1
	# Clear enemies died on Gamemanager
	var scene_path = _get_level_path(GameManager.current_level)
	get_tree().change_scene_to_file(scene_path)

func old_scene() -> void:
	crt_animation.play("brightness_fade_in")
	await get_tree().create_timer(FADE_DURATION).timeout
	# Game lock (player actions (interact and movement), enemies, etc...)
	GameManager.current_level -= 1
	# Clear enemies died on Gamemanager
	var scene_path = _get_level_path(GameManager.current_level)
	get_tree().change_scene_to_file(scene_path)

func _get_level_path(level_number: int) -> String:
	return LEVEL_PATH_PREFIX + str(level_number) + LEVEL_PATH_SUFFIX
