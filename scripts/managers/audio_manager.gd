class_name AudioManager extends Node

# Nodes
@onready var main_menu: MainMenu = %MainMenu
@onready var animation_manager: AnimationManager = %AnimationManager
@onready var scene_manager: SceneManager = %SceneManager
@onready var event_manager: EventManager = %EventManager
# Audio Players
@export var music: AudioStreamPlayer
@export var menu_focus: AudioStreamPlayer
@export var menu_select: AudioStreamPlayer
@export var crt_noise: AudioStreamPlayer

# Files
@export_category("Music")
@export var level_0_to_1_music: AudioStream
@export var level_2_to_3_music: AudioStream
@export var combat_base_music: AudioStream

# Variables
const EPSILON: float = 0.0001

func _ready() -> void:
	main_menu.button_focus_entered.connect(_button_focus_entered)
	main_menu.button_selected.connect(_button_selected)
	animation_manager.noise_changed.connect(_on_noise_changed)
	scene_manager.level_changed.connect(_play_level_music)
	scene_manager.returned_to_main_menu.connect(_play_level_music)
	scene_manager.combat_finished.connect(_play_level_music)
	event_manager.combat_started.connect(_play_combat_music)
	crt_noise.play()
	_on_noise_changed(0.0)
	_play_level_music()

# Menu functions
func _button_focus_entered() -> void:
	menu_focus.play()

func _button_selected() -> void:
	menu_select.play()

# Music functions
func _play_level_music() -> void:
	_play_music(_level_music(scene_manager.current_level))

func _play_combat_music(_enemy_node: Node) -> void:
	_play_music(combat_base_music)

func _level_music(level: int) -> AudioStream:
	match level:
		0, 1:
			return level_0_to_1_music
		2, 3:
			return level_2_to_3_music
		_:
			return level_0_to_1_music

func _play_music(stream: AudioStream) -> void:
	if stream == null or music.stream == stream:
		return
	music.stream = stream
	music.play()

# Noise functions
func _on_noise_changed(intensity: float) -> void:
	music.volume_db = linear_to_db(maxf(1.0 - intensity, EPSILON))
	crt_noise.volume_db = linear_to_db(maxf(intensity, EPSILON))
