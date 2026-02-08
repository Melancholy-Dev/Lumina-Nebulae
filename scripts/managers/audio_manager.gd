extends Node

@onready var player_a: AudioStreamPlayer = $"../../AudioStreamPlayer"
@onready var player_b: AudioStreamPlayer = $"../../AudioStreamPlayer/FadeCRT"

var crossfade_time: float = 4.0
var current: float = 0.0
var crossfading: bool = false
#var crossfading_end: bool = false

func start_crt_audio_crossfade(duration: float) -> void:
	crossfade_time = max(0.01, duration)
	player_a.volume_db = linear_to_db(1.0)
	player_b.volume_db = linear_to_db(0.0)
	if not player_b.playing:
		player_b.play()
	current = 0.0
	crossfading = true

# Fade out
#func end_crt_audio_crossfade(duration: float) -> void:
	#crossfade_time = max(0.01, duration)
	#player_a.volume_db = linear_to_db(0.0)
	#player_b.volume_db = linear_to_db(1.0)
	#if not player_a.playing:
		#player_a.play()
	#current = 0.0
	#crossfading_end = true

func _process(delta: float) -> void:
	if crossfading:
		current += delta
		var fade = clamp(current / crossfade_time, 0.0, 1.0)
		var vol_a = lerp(1.0, 0.0, fade)
		var vol_b = lerp(0.0, 1.0, fade)
		player_a.volume_db = linear_to_db(vol_a)
		player_b.volume_db = linear_to_db(vol_b)
		if fade >= 1.0:
			crossfading = false
			player_a.stop()
	#elif crossfading_end:
		#current += delta
		#var fade = clamp(current / crossfade_time, 0.0, 1.0)
		#var vol_a = lerp(0.0, 1.0, fade)
		#var vol_b = lerp(1.0, 0.0, fade)
		#player_a.volume_db = linear_to_db(vol_a)
		#player_b.volume_db = linear_to_db(vol_b)
		#if fade >= 1.0:
			#crossfading_end = false
			#player_b.stop()
