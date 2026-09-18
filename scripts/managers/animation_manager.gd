class_name AnimationManager extends Node

# Signals
signal fade_in_started
signal fade_out_started
signal fade_in_ended
signal fade_out_ended
signal noise_changed(intensity: float)

# Nodes
@onready var scene_manager: SceneManager = %SceneManager
@onready var event_manager: EventManager = %EventManager
@onready var main_menu: MainMenu = %MainMenu
@onready var crt: ColorRect = %CRT
@export var crt_animation: AnimationPlayer

# Variables
const SHADER_NOISE_PARAM: String = "shader_parameter/static_noise_intensity"
const NOISE_MIN: float = 0.06  # CRT shader default
const NOISE_MAX: float = 1.0
const NOISE_RAMP_TIME: float = 4.0
var shader_tween: Tween
var noise_intensity: float = 0.0

func _ready() -> void:
	crt_animation.animation_finished.connect(_on_animation_finished)
	main_menu.button_selected.connect(play_fade_in)
	main_menu.new_menu_loaded.connect(play_fade_out)
	scene_manager.interacted.connect(play_fade_in)
	scene_manager.level_changed.connect(play_fade_out)
	scene_manager.combat_finished.connect(_on_combat_finished)
	event_manager.combat_area_entered.connect(_on_combat_area_entered)
	event_manager.combat_area_exited.connect(_on_combat_area_exited)
	event_manager.combat_started.connect(_on_combat_started)

func play_fade_in(_level_number: int = 0) -> void:
	fade_in_started.emit()
	crt_animation.play("brightness_fade_in")

func play_fade_out() -> void:
	fade_out_started.emit()
	crt_animation.play("brightness_fade_out")

func _on_animation_finished(anim_name: StringName) -> void:
	match anim_name:
		&"brightness_fade_in":
			fade_in_ended.emit()
		&"brightness_fade_out":
			fade_out_ended.emit()
		_:
			push_error("Animation does not exist: %s" % anim_name)

func _on_combat_finished() -> void:
	play_fade_in()
	await fade_in_ended
	play_fade_out()

func _on_combat_area_entered(_enemy_node: Node) -> void:
	_noise_transition(1.0)

func _on_combat_area_exited() -> void:
	_noise_transition(0.0)

func _on_combat_started(_enemy_node: Node) -> void:
	if shader_tween:
		shader_tween.kill()
	_set_noise(0.0)

func _noise_transition(target: float) -> void:
	if shader_tween:
		shader_tween.kill()
	shader_tween = create_tween()
	shader_tween.tween_method(_set_noise, noise_intensity, target, NOISE_RAMP_TIME)

func _set_noise(intensity: float) -> void:
	noise_intensity = intensity
	crt.material.set(SHADER_NOISE_PARAM, lerpf(NOISE_MIN, NOISE_MAX, intensity))
	noise_changed.emit(intensity)
