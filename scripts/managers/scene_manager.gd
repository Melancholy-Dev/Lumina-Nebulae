class_name SceneManager extends Node

# Signals
signal game_started
signal level_changed
signal returned_to_main_menu
signal interacted
signal combat_finished

# Nodes
@onready var main_menu: MainMenu = %MainMenu
@onready var animation_manager: AnimationManager = %AnimationManager
@onready var event_manager: EventManager = %EventManager
@onready var combat_ui: Node = %Combat
@export var fixed_hud_game: CanvasLayer
@export var world: Node2D
@export var levels_root: Node2D
@export var enemies_root: Node2D

# Variables
var current_level: int = 0  # 0 = Main Menu, 1+ = Level number
var _player_instance: Node = null
var _combat_system: Node = null
var came_from_main_menu: bool = false
var _pending_spawn_point_id: int = 0

func _ready() -> void:
	main_menu.new_game_created.connect(_on_new_game)
	main_menu.game_loaded.connect(_on_load_game)
	event_manager.combat_started.connect(_on_combat_started)
	_combat_system = combat_ui.get_node("CombatSystem")
	_combat_system.combat_ended.connect(_on_combat_ended)
	_combat_system.combat_fled.connect(_on_combat_fled)

func _on_new_game() -> void:
	current_level = 1
	came_from_main_menu = true
	_pending_spawn_point_id = 0
	_game_started()
	load_level(current_level)

func _on_load_game() -> void:
	# TODO: Load save slot (with current level)
	pass

func _game_started() -> void:
	game_started.emit()
	world.visible = true
	fixed_hud_game.visible = true
	main_menu.visible = false

func load_next_level() -> void:
	current_level += 1
	load_level(current_level)

func load_previous_level() -> void:
	if current_level > 1:
		current_level -= 1
		load_level(current_level)

func load_level(level_to_load: int) -> void:
	if level_to_load < 1:
		push_error("Invalid level number: %d" % level_to_load)
		return
	current_level = level_to_load
	came_from_main_menu = false
	var scene_path := "res://scenes/levels/level_%d.tscn" % level_to_load
	var level_scene := load(scene_path)
	if level_scene == null:
		push_error("Scene not found: %s" % scene_path)
		return
	# Clear old level and its enemies
	for child in levels_root.get_children():
		child.queue_free()
	for child in enemies_root.get_children():
		child.queue_free()
	# Load new level
	var level: Node = level_scene.instantiate()
	level.name = "Level%d" % level_to_load
	levels_root.add_child(level)
	_spawn_enemies(level)
	_connect_interactables(level)
	level_changed.emit()
	call_deferred("_position_player_at_spawn", level) # Player position

func _spawn_enemies(node: Node) -> void:
	if node is EnemySpawn:
		var spawn := node as EnemySpawn
		if not spawn.enemy_scene:
			push_error("EnemySpawn '%s' has no enemy scene" % spawn.name)
			return
		var enemy: Node2D = spawn.enemy_scene.instantiate()
		# Placed before entering the tree so the enemy starts its patrol from here
		enemy.global_position = spawn.global_position
		enemies_root.add_child(enemy)
		return
	for child in node.get_children():
		_spawn_enemies(child)

func _connect_interactables(node: Node) -> void:
	if node is Interactable:
		node.interacted.connect(_on_interacted)
	for child in node.get_children():
		_connect_interactables(child)

func _position_player_at_spawn(level: Node) -> void:
	var player_node = world.get_node("Entities/Player")
	var spawn_node = level.find_child("PlayerPos%d" % _pending_spawn_point_id, true, false)
	if spawn_node:
		player_node.global_position = spawn_node.global_position
	else:
		push_error("Spawn point PlayerPos%d not found in level" % _pending_spawn_point_id)

func _on_interacted(interactable: Interactable) -> void:
	var type: StringName = interactable.type
	match type:
		&"StairsNew":
			_pending_spawn_point_id = interactable.spawn_point_id
			interacted.emit()
			await animation_manager.fade_in_ended
			load_next_level()
		&"StairsOld":
			_pending_spawn_point_id = interactable.spawn_point_id
			interacted.emit()
			await animation_manager.fade_in_ended
			load_previous_level()
		_:
			push_error("Type does not exist: %s" % String(type))

func _on_combat_started(enemy_node: Node) -> void:
	_player_instance = world.get_node("Entities/Player")
	var player_combat = _player_instance.get_node("Components/PlayerCombat")
	var enemy_combat = enemy_node.get_node("Components/EnemyCombat")
	_combat_system.start_combat(player_combat, enemy_combat)
	combat_ui.visible = true
	_set_world_paused(true)

func _on_combat_ended(victory: bool) -> void:
	await _end_combat()
	if not victory:
		return_to_main_menu()
	# TODO Enemy drops

func _on_combat_fled() -> void:
	await _end_combat()

func _end_combat() -> void:
	combat_finished.emit()
	await animation_manager.fade_in_ended
	_set_world_paused(false)
	combat_ui.visible = false
	_player_instance = null

func _set_world_paused(paused: bool) -> void:
	world.process_mode = Node.PROCESS_MODE_DISABLED if paused else Node.PROCESS_MODE_INHERIT

func return_to_main_menu() -> void:
	current_level = 0
	world.visible = false
	fixed_hud_game.visible = false
	combat_ui.visible = false
	for child in levels_root.get_children():
		child.queue_free()
	for child in enemies_root.get_children():
		child.queue_free()
	main_menu.visible = true
	returned_to_main_menu.emit()

func get_current_level() -> int:
	return current_level

func is_in_level() -> bool:
	return current_level > 0
