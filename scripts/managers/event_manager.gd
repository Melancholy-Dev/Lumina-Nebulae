extends Node

@onready var color_rect: ColorRect = $"../../CanvasLayer/CRT"
@onready var audio_manager: Node = $"../AudioManager"

func _on_combat_area_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player"):
		print("--------------------------------------------")
		print("Player HP: " + str(GameManager.player_hp))
		var mat = color_rect.material
		if mat and mat is ShaderMaterial:
			var start_val : float = 0.06
			var end_val : float = 1
			var duration : float = 4
			
			# Animations
			audio_manager.start_crt_audio_crossfade(duration)
			mat.set_shader_parameter("static_noise_intensity", start_val)
			var tween := create_tween()
			tween.tween_property(mat, "shader_parameter/static_noise_intensity", end_val, duration).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
			await tween.finished

			# Loading combat scene
			# TODO use the same CRT shader and do a fade-out in the combat scene
			get_tree().change_scene_to_packed(load("res://scenes/combat.tscn"))
