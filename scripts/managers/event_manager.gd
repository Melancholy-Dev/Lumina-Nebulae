extends Node

# Nodes
@onready var player: CharacterBody2D = $"../../Player"
@onready var crt: ColorRect = $"../../UI/CRT"
@onready var audio_manager: Node = $"../AudioManager"
@onready var crt_animation: AnimationPlayer = $"../../UI/CRT/AnimationPlayer"
@onready var timer: Timer = $"../../UI/CRT/Timer"

# Variables
var current_event: String
@export var enemy_node_path: NodePath

func _ready() -> void:
	# Delete the last 3 enemies
	if enemy_died() or GameManager.player_flee:
		player.position = GameManager.last_player_pos
		GameManager.player_flee = false
	# Animations
	crt_animation.play("RESET")
	crt_animation.play("brightness_fade_out")

func enemy_died() -> bool:
	if not GameManager.is_last_enemy_died:
		return false
	var paths = [
		GameManager.last_enemy,
		GameManager.last_enemy2,
		GameManager.last_enemy3
	]
	for p in paths:
		if p == null:
			continue
		var node: Node = null
		if typeof(p) == TYPE_NODE_PATH or typeof(p) == TYPE_STRING:
			if has_node(p):
				node = get_node(p)
		elif p is Node:
			node = p
		if node and node.is_inside_tree():
			queue_free_enemy(node)
	GameManager.enemies_died += 1
	GameManager.is_last_enemy_died = false
	return true

func queue_free_enemy(enemy: Node) -> void:
	if enemy and enemy.is_inside_tree():
		enemy.queue_free()


func _on_combat_trigger_area_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		current_event = "starting_combat"
		# Animations
		var mat = crt.material
		if mat and mat is ShaderMaterial:
			timer.start()
			audio_manager.start_crt_audio_crossfade(4.0)
			crt_animation.play("static_noise_fade_in")

func _on_combat_trigger_area_body_exited(body: Node2D) -> void:
	if body.is_in_group("player"):
		current_event = "none"
		# Animations
		var mat = crt.material
		if mat and mat is ShaderMaterial:
			timer.stop()
			audio_manager.stop_crt_audio_crossfade(4.0)
			crt_animation.play("RESET")

func _on_timer_timeout() -> void:
	# Change scene
	GameManager.last_player_pos = player.position
	if current_event == "starting_combat":
		get_tree().change_scene_to_packed(load("res://scenes/combat.tscn"))
