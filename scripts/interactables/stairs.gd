extends Node

# Variables
@onready var player: CharacterBody2D = $"../Player"
@onready var next_player_position_up: Node2D = $NextPlayerPositionUp
@onready var next_player_position_down: Node2D = $NextPlayerPositionDown
@onready var crt_animation: AnimationPlayer = $"../UI/CRT/AnimationPlayer"

func player_go_up() -> void:
	crt_animation.play("brightness_fade_in")
	await get_tree().create_timer(1.0).timeout
	player.position = next_player_position_up.position
	crt_animation.play("brightness_fade_out")

func player_go_down() -> void:
	crt_animation.play("brightness_fade_in")
	await get_tree().create_timer(1.0).timeout
	player.position = next_player_position_down.position
	crt_animation.play("brightness_fade_out")
