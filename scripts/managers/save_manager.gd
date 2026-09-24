class_name SaveManager extends Node

# Signals
signal game_saved
signal save_loaded(data: Dictionary)
signal save_refused

# Nodes
@onready var scene_manager: SceneManager = get_tree().get_first_node_in_group("scene_manager")
@onready var event_manager: EventManager = get_tree().get_first_node_in_group("event_manager")

# Variables
const SAVE_VERSION: int = 1
@export var save_path: String = "user://savegame.json"
var defeated_enemies: Dictionary = {}

func _ready() -> void:
	if scene_manager:
		scene_manager.enemy_defeated.connect(mark_enemy_defeated)

func has_save() -> bool:
	return FileAccess.file_exists(save_path)

func save_game() -> void:
	if event_manager.is_being_chased():
		save_refused.emit()
		return
	var player: Node2D = get_tree().get_first_node_in_group("player")
	var stats: PlayerStats = player.get_node_or_null("Components/PlayerStats")
	var data: Dictionary = {
		"version": SAVE_VERSION,
		"level": scene_manager.get_current_level(),
		"player_position": [player.global_position.x, player.global_position.y],
		"stats": {
			"hp": stats.hp,
			"max_hp": stats.max_hp,
			"vyrn": stats.vyrn,
			"max_vyrn": stats.max_vyrn,
			"stamina": stats.stamina,
			"max_stamina": stats.max_stamina,
			"attack_damage": stats.attack_damage
		},
		"defeated_enemies": defeated_enemies
	}
	var file := FileAccess.open(save_path, FileAccess.WRITE)
	file.store_string(JSON.stringify(data, "\t"))
	file.close()
	game_saved.emit()

func read_save() -> Dictionary:
	if not has_save():
		push_warning("SaveManager: no save slot at %s" % save_path)
		return {}
	var file := FileAccess.open(save_path, FileAccess.READ)
	var parsed = JSON.parse_string(file.get_as_text())
	file.close()
	if not parsed is Dictionary:
		push_error("SaveManager: corrupted save slot at %s" % save_path)
		return {}
	return parsed

func apply_save(data: Dictionary) -> void:
	defeated_enemies = data.get("defeated_enemies", {})
	save_loaded.emit(data)

func is_enemy_defeated(level: int, enemy_name: String) -> bool:
	return defeated_enemies.get(str(level), []).has(enemy_name)

func mark_enemy_defeated(level: int, enemy_name: String) -> void:
	var key := str(level)
	if not defeated_enemies.has(key):
		defeated_enemies[key] = []
	if not defeated_enemies[key].has(enemy_name):
		defeated_enemies[key].append(enemy_name)
