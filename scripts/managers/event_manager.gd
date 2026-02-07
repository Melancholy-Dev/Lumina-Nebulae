extends Node

# Nodes
@onready var crt: ColorRect = $"../../CanvasLayer/CRT"
@onready var audio_manager: Node = $"../AudioManager"
@onready var crt_animation: AnimationPlayer = $"../../CanvasLayer/CRT/AnimationPlayer"
@onready var timer: Timer = $"../../CanvasLayer/CRT/Timer"

# Variables
var current_event: String

func _ready() -> void:
	crt_animation.play("brightness_fade_out")

func _on_combat_area_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player"):
		print("--------------------------------------------")
		print("Player HP: " + str(GameManager.player_hp))
		var mat = crt.material
		if mat and mat is ShaderMaterial:
			# Animations
			timer.start()
			audio_manager.start_crt_audio_crossfade(4.0)
			crt_animation.play("static_noise_fade_in")
			current_event = "starting_combat"


func _on_timer_timeout() -> void:
	# TODO use the same CRT shader and do a fade-out in the combat scene
	if current_event == "starting_combat":
		get_tree().change_scene_to_packed(load("res://scenes/combat.tscn"))
