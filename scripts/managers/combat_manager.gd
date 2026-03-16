extends Node

# Nodes
@onready var hp_label: Label = $"../PlayerStats/HpContainer/PanelContainer/HpLabel"
@onready var vyrn_label: Label = $"../PlayerStats/Vyrn/PanelContainer/VyrnLabel"
@onready var state_label: Label = $"../EnemyState/StateContainer/PanelContainer/StateLabel"
@onready var crt_animation: AnimationPlayer = $"../CanvasLayer/CRT/AnimationPlayer"
@onready var audio_manager: Node = $AudioManager
@onready var buttons_ui: Node = $"../Buttons"
@onready var player: Node = $"../Player"
@onready var enemy: Node = $"../Enemy"
@onready var enemy_sprite: AnimatedSprite2D = $"../Enemy/EnemySprite"

# Constants
const LEVEL_PATH_PREFIX: String = "res://scenes/levels/level_"
const LEVEL_PATH_SUFFIX: String = ".tscn"

# Variables
@onready var buttons: Array[Button] = []
var player_turn: bool = true

# Vyrn costs
var player_spell_1_cost: int = 10
var enemy_spell_1_cost: int = 10

#### Management functions
func _ready() -> void:
	GameManager.order_enemies_died()
	# Animations
	crt_animation.play("RESET")
	var s = GameManager.last_enemy_sprite_state
	if s and s.sprite_frames:
		enemy_sprite.sprite_frames = s.sprite_frames
		enemy_sprite.animation = s.animation
		enemy_sprite.frame = s.frame
		enemy_sprite.play()
	else:
		push_error("No saved sprite state")
	enemy.init(100, 50, 10) # Max_HP, Vyrn, Damage
	_update_ui()
	for node in get_tree().get_nodes_in_group("ui_button"):
		if node is Button:
			buttons.append(node as Button)
	buttons[0].grab_focus()

func _update_ui() -> void:
	hp_label.text = "HP: " + str(GameManager.player_hp)
	vyrn_label.text = "Vyrn: " + str(GameManager.player_vyrn)
	state_label.text = "State: " + str(enemy.get_enemy_state())

func _update_buttons_visibility(visible: bool) -> void:
	buttons_ui.visible = visible
	if visible and buttons.size() > 0:
		buttons[0].grab_focus()

func _get_level_path(level_number: int) -> String:
	return LEVEL_PATH_PREFIX + str(level_number) + LEVEL_PATH_SUFFIX


#### Signals
# Enemy signal
func _on_enemy_pass_turn() -> void:
	if not is_inside_tree():
		return
	_update_ui()
	player_turn = true
	_update_buttons_visibility(true)
	await get_tree().process_frame
	_enemy_turn()

func _on_enemy_damaged(_amount: int) -> void:
	print("Enemy HP: " + str(enemy.hp))
	_update_ui()

func _on_enemy_died() -> void:
	print("Enemy Died")
	GameManager.is_last_enemy_died = true
	var scene_path = _get_level_path(GameManager.current_level)
	get_tree().change_scene_to_file(scene_path)


# Player signals
func _on_player_pass_turn() -> void:
	if not is_inside_tree():
		return
	player_turn = false
	_update_buttons_visibility(false)
	_update_ui()
	await get_tree().process_frame
	_enemy_turn()

func _on_player_damaged(_amount: int) -> void:
	print("Player HP: " + str(GameManager.player_hp))
	_update_ui()

func _on_player_died() -> void:
	print("Player Died")
	player.init()
	get_tree().change_scene_to_packed(load("res://scenes/game.tscn"))

func _enemy_turn() -> void:
	if player_turn:
		return
	var actions: int = 2
	var enemy_action: int = randi() % actions
	match enemy_action:
		0:
			print("Enemy perform attack")
			enemy_attack()
		1:
			print("Enemy perform spell")
			if enemy_spell() != true:
				print("Enemy perform attack (vyrn runned out)")
				enemy_attack()

#### Actions
# Player actions
func _on_fight_button_pressed() -> void:
	print("Player perform attack")
	player.perform_attack()
	player.emit_signal("pass_turn")

func _on_spell_button_pressed() -> bool:
	print("Player perform spell")
	if (GameManager.player_vyrn >= player_spell_1_cost):
		GameManager.player_vyrn -= player_spell_1_cost
		player.perform_attack()
		player.perform_attack() # Double attack, placeholder
		player.emit_signal("pass_turn")
		return true
	else:
		print("Error, player vyrn is out and can't perform the spell")
		return false

func _on_item_button_pressed() -> void:
	pass

func _on_flee_button_pressed() -> void:
	GameManager.player_flee = true
	var scene_path = _get_level_path(GameManager.current_level)
	get_tree().change_scene_to_file(scene_path)


# Enemy actions
func enemy_attack() -> void:
	enemy.perform_attack();
	# Implement Animations
	enemy.emit_signal("pass_turn")
	
func enemy_spell() -> bool:
	if (enemy.vyrn >= enemy_spell_1_cost):
		enemy.vyrn -= enemy_spell_1_cost
		enemy.perform_attack();
		enemy.perform_attack(); # Double attack, placeholder
		# Implement Animations
		enemy.emit_signal("pass_turn")
		return true
	else:
		print("Error, enemy vyrn is out and can't perform the spell")
		return false
