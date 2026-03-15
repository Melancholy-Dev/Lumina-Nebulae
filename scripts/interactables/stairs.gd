extends Node

# Variables
@onready var player: CharacterBody2D = $"../Player"
@onready var next_player_position_up: Node2D = $NextPlayerPositionUp
@onready var next_player_position_down: Node2D = $NextPlayerPositionDown
@onready var crt_animation: AnimationPlayer = $"../UI/CRT/AnimationPlayer"

func go_up() -> void:
	crt_animation.play("brightness_fade_in")
	await get_tree().create_timer(1.0).timeout
	# Game lock (player actions (interact and movement), enemies, etc...)
	player.position = next_player_position_up.position
	crt_animation.play("brightness_fade_out")

func go_down() -> void:
	crt_animation.play("brightness_fade_in")
	await get_tree().create_timer(1.0).timeout
	# Game lock (player actions (interact and movement), enemies, etc...)
	player.position = next_player_position_down.position
	crt_animation.play("brightness_fade_out")

func new_scene() -> void:
	crt_animation.play("brightness_fade_in")
	await get_tree().create_timer(1.0).timeout
	# Game lock (player actions (interact and movement), enemies, etc...)
	GameManager.current_level += 1
	get_tree().change_scene_to_file("res://scenes/levels/level_"+str(GameManager.current_level)+".tscn")

func old_scene() -> void:
	crt_animation.play("brightness_fade_in")
	await get_tree().create_timer(1.0).timeout
	# Game lock (player actions (interact and movement), enemies, etc...)
	GameManager.current_level -= 1
	get_tree().change_scene_to_file("res://scenes/levels/level_"+str(GameManager.current_level)+".tscn")
