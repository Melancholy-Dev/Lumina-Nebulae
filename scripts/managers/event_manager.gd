extends Node

# Nodes
@onready var crt: ColorRect = $"../../UI/CRT"
@onready var audio_manager: Node = $"../AudioManager"
@onready var crt_animation: AnimationPlayer = $"../../UI/CRT/AnimationPlayer"
@onready var timer: Timer = $"../../UI/CRT/Timer"

# Variables
var current_event: String
@export var enemy_node_path: NodePath

func _ready() -> void:
	# Animations
	crt_animation.play("brightness_fade_out")
	on_enemy_died()

func on_enemy_died() -> void:
	var enemy_died = get_node(GameManager.last_enemy_died)
	if enemy_died:
		enemy_died.queue_free()

func _on_combat_area_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		# Animations
		var mat = crt.material
		if mat and mat is ShaderMaterial:
			timer.start()
			audio_manager.start_crt_audio_crossfade(4.0)
			crt_animation.play("static_noise_fade_in")
			current_event = "starting_combat"

func _on_timer_timeout() -> void:
	# Change scene
	if current_event == "starting_combat":
		get_tree().change_scene_to_packed(load("res://scenes/combat.tscn"))
