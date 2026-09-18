class_name AudioComponent extends Node

# Nodes
@export var mc: MovementComponent
@export var footstep_timer: Timer
@export var footstep_player: AudioStreamPlayer

# Variables
var base_step_interval := 0.5
var run_pitch_multiplier := 1.25

func _ready() -> void:
	footstep_timer.timeout.connect(_play_footstep)
	mc.is_walking.connect(_start_footsteps)
	mc.is_idle.connect(_stop_footsteps)
	mc.run_changed.connect(_on_run_changed)

func _start_footsteps() -> void:
	if footstep_timer.is_stopped():
		_play_footstep()
		footstep_timer.start()

func _stop_footsteps() -> void:
	footstep_timer.stop()
	footstep_player.stop()

func _on_run_changed(_is_running: bool) -> void:
	if footstep_timer.is_stopped():
		return
	var phase: float = footstep_timer.time_left / footstep_timer.wait_time
	var interval := _step_interval()
	footstep_timer.start(interval * phase)
	footstep_timer.wait_time = interval

func _play_footstep() -> void:
	_apply_step_speed()
	footstep_player.play()

func _apply_step_speed() -> void:
	footstep_timer.wait_time = _step_interval()
	if mc.is_running:
		footstep_player.pitch_scale = run_pitch_multiplier
	else:
		footstep_player.pitch_scale = 1.0

func _step_interval() -> float:
	if mc.is_running:
		return base_step_interval / mc.RUN_MULTIPLIER
	else:
		return base_step_interval
