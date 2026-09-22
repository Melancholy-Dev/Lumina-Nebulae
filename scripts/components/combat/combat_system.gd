class_name CombatSystem extends Node

# Signals
signal combat_started(player_combat: Node, enemy_combat: Node)
signal turn_changed(is_player_turn: bool)
signal player_turn_started
signal enemy_turn_started
signal combat_resolved(victory: bool)
signal combat_ended(victory: bool)
signal combat_fled

# Nodes
@export var player_combat: BaseCombatEntity
@export var enemy_combat: BaseCombatEntity
@export var ui_buttons: Node
@export var enemy_state_label: EnemyStateLabel
@export var player_combat_hud: PlayerCombatHUD
@export var enemy_sprite: AnimatedSprite2D
@export var combat_result: CombatResult

# Constants
const ENEMY_ACTIONS: int = 2
var player_spell_cost: int = 10
var enemy_spell_cost: int = 10

# State
var _is_player_turn: bool = true
var _combat_active: bool = false

func _ready() -> void:
	_setup_ui_buttons()

func _setup_ui_buttons() -> void:
	var fight_btn := ui_buttons.find_child("FightButton") as Button
	var spell_btn := ui_buttons.find_child("SpellButton") as Button
	var item_btn := ui_buttons.find_child("ItemButton") as Button
	var flee_btn := ui_buttons.find_child("FleeButton") as Button

	fight_btn.pressed.connect(_on_fight_pressed)
	spell_btn.pressed.connect(_on_spell_pressed)
	item_btn.pressed.connect(_on_item_pressed)
	flee_btn.pressed.connect(_on_flee_pressed)

func _setup_connections() -> void:
	if not player_combat.pass_turn.is_connected(_on_player_pass_turn):
		player_combat.pass_turn.connect(_on_player_pass_turn)
	if not player_combat.died.is_connected(_on_player_died):
		player_combat.died.connect(_on_player_died)
	if not enemy_combat.pass_turn.is_connected(_on_enemy_pass_turn):
		enemy_combat.pass_turn.connect(_on_enemy_pass_turn)
	if not enemy_combat.died.is_connected(_on_enemy_died):
		enemy_combat.died.connect(_on_enemy_died)

func start_combat(player: BaseCombatEntity, enemy: BaseCombatEntity) -> void:
	player_combat = player
	enemy_combat = enemy
	_combat_active = true
	_is_player_turn = true
	_setup_connections()
	# Show sprite
	var enemy_entity := enemy as EnemyCombat
	enemy_state_label.enemy_stats = enemy_entity.enemy_stats
	enemy_sprite.sprite_frames = enemy_entity.sprite.sprite_frames
	enemy_sprite.play(enemy_entity.sprite.animation)
	# Player stats
	var player_entity := player as PlayerCombat
	player_combat_hud.player_stats = player_entity.player_stats
	combat_started.emit(player_combat, enemy_combat)
	_set_buttons_visible(true)
	player_turn_started.emit()
	turn_changed.emit(true)

func _on_player_pass_turn() -> void:
	if not _combat_active or not _is_player_turn:
		return
	_is_player_turn = false
	_set_buttons_visible(false)
	turn_changed.emit(false)
	await get_tree().process_frame
	_enemy_turn()

func _on_enemy_pass_turn() -> void:
	if not _combat_active or _is_player_turn:
		return
	_is_player_turn = true
	_set_buttons_visible(true)
	turn_changed.emit(true)
	await get_tree().process_frame
	player_turn_started.emit()

func _enemy_turn() -> void:
	if not _combat_active or _is_player_turn:
		return

	var action = randi() % ENEMY_ACTIONS
	match action:
		0:
			_enemy_attack()
		1:
			if not _enemy_spell():
				_enemy_attack()

func _enemy_attack() -> void:
	enemy_combat.perform_attack(player_combat)
	enemy_combat.emit_signal("pass_turn")

func _enemy_spell() -> bool:
	if enemy_combat.consume_vyrn(enemy_spell_cost):
		enemy_combat.perform_attack(player_combat)
		enemy_combat.perform_attack(player_combat) # Double attack
		enemy_combat.emit_signal("pass_turn")
		return true
	return false

func _on_fight_pressed() -> void:
	if not _combat_active or not _is_player_turn:
		return
	player_combat.perform_attack(enemy_combat)
	player_combat.emit_signal("pass_turn")

func _on_spell_pressed() -> void:
	if not _combat_active or not _is_player_turn:
		return
	if player_combat.consume_vyrn(player_spell_cost):
		player_combat.perform_attack(enemy_combat)
		player_combat.perform_attack(enemy_combat) # Double attack
		player_combat.emit_signal("pass_turn")
	else:
		print("Not enough Vyrn for spell")

func _on_item_pressed() -> void:
	# TODO: Implement item usage
	pass

func _on_flee_pressed() -> void:
	if not _combat_active:
		return
	_combat_active = false
	combat_fled.emit()

func _on_player_died() -> void:
	await _play_ending(false)

func _on_enemy_died() -> void:
	await _play_ending(true)

func _play_ending(victory: bool) -> void:
	if not _combat_active:
		return
	_combat_active = false
	_set_buttons_visible(false)
	combat_resolved.emit(victory)
	await combat_result.finished
	combat_ended.emit(victory)

func _set_buttons_visible(visible: bool) -> void:
	ui_buttons.visible = visible
	if visible:
		var first_btn := ui_buttons.find_child("FightButton") as Button
		first_btn.grab_focus()

func is_player_turn() -> bool:
	return _is_player_turn

func is_combat_active() -> bool:
	return _combat_active
