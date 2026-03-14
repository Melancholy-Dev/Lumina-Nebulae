extends Node

# Variables
@onready var player: CharacterBody2D = $"../Player"
@onready var next_player_position_up: Node2D = $NextPlayerPositionUp
@onready var next_player_position_down: Node2D = $NextPlayerPositionDown

func player_go_up():
	player.position = next_player_position_up.position

func player_go_down():
	player.position = next_player_position_down.position
