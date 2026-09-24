class_name EventManager extends Node

# Signals
signal combat_started(enemy_node: Node)
signal combat_area_entered(enemy_node: Node)
signal combat_area_exited

# Nodes
@onready var timer_combat: Timer = %TimerCombat
@onready var timer_leave: Timer = %TimerLeave
@onready var scene_manager: SceneManager = %SceneManager

# Variables
var pending_enemy: Node = null
var combat_areas: Array[Area2D] = []

func _ready() -> void:
	timer_combat.timeout.connect(_on_timer_timeout)
	timer_leave.timeout.connect(_on_leave_timeout)
	scene_manager.level_changed.connect(_on_level_changed)

func _on_level_changed(_level_number: int = 0) -> void:
	timer_leave.stop()
	_cancel_combat()
	combat_area_exited.emit()
	for area in combat_areas:
		if is_instance_valid(area):
			area.player_entered.disconnect(_on_combat_area_entered)
			area.player_exited.disconnect(_on_combat_area_exited)
	combat_areas.clear()
	_find_combat_areas(scene_manager.enemies_root)

func _find_combat_areas(node: Node) -> void:
	for child in node.get_children():
		if child is CombatTriggerArea:
			combat_areas.append(child)
			child.player_entered.connect(_on_combat_area_entered)
			child.player_exited.connect(_on_combat_area_exited)
		_find_combat_areas(child)

func _on_combat_area_entered(enemy_node: Node) -> void:
	timer_leave.stop()
	if not timer_combat.is_stopped():
		return
	pending_enemy = enemy_node
	timer_combat.start()
	combat_area_entered.emit(enemy_node)

func _on_combat_area_exited(_enemy_node: Node) -> void:
	timer_leave.start()

func _on_leave_timeout() -> void:
	if _player_in_any_area():
		return
	_cancel_combat()
	combat_area_exited.emit()

func _player_in_any_area() -> bool:
	var player: Node = get_tree().get_first_node_in_group("player")
	if player == null:
		return false
	for area in combat_areas:
		if is_instance_valid(area) and area.overlaps_body(player):
			return true
	return false

func is_being_chased() -> bool:
	return _player_in_any_area()

func _cancel_combat() -> void:
	pending_enemy = null
	timer_combat.stop()

func _on_timer_timeout() -> void:
	if pending_enemy:
		combat_started.emit(pending_enemy)
		pending_enemy = null
