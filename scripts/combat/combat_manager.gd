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

# Variables
@onready var buttons: Array[Button] = []
var player_turn: bool = true

# Vyrn costs
var player_spell_1_cost: int = 10
var enemy_spell_1_cost: int = 10

#### Management functions
func _ready() -> void:
	# Player stats
	hp_label.text = "HP: " + str(GameManager.player_hp)
	vyrn_label.text = "Vyrn: " + str(GameManager.player_vyrn)
	# Animations
	crt_animation.play("RESET")
	#audio_manager.end_crt_audio_crossfade(4.0)
	# Init
	enemy.init(100, 50, 10) # Max_HP, Vyrn, Damage
	for node in get_tree().get_nodes_in_group("ui_button"):
		if node is Button:
			buttons.append(node as Button)
	buttons[0].grab_focus()

func _process(delta: float) -> void:
	#var focused = get_viewport().gui_get_focus_owner()
	#if focused and focused is Button:
		#focused.emit_signal("pressed")
	if player_turn:
		buttons_ui.visible = true
	else:
		buttons_ui.visible = false
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



#### Signals
# Enemy signal
func _on_enemy_pass_turn() -> void:
	hp_label.text = "HP: " + str(GameManager.player_hp)
	vyrn_label.text = "Vyrn: " + str(GameManager.player_vyrn)
	player_turn = true
	if buttons.size() > 0:
		buttons[0].call_deferred("grab_focus")

func _on_enemy_damaged(amount: int) -> void:
	print("Enemy HP: " + str(enemy.hp))

func _on_enemy_died() -> void:
	print("Enemy Died")
	get_tree().change_scene_to_packed(load("res://scenes/game.tscn"))


# Player signals
func _on_player_pass_turn() -> void:
	player_turn = false
	state_label.text = "State: " + str(enemy.get_enemy_state())

func _on_player_damaged(amount: int) -> void:
	print("Player HP: " + str(GameManager.player_hp))

func _on_player_died() -> void:
	print("Player Died")
	player._ready()
	get_tree().change_scene_to_packed(load("res://scenes/game.tscn"))



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
		# Animations
		player.emit_signal("pass_turn")
		return true
	else:
		print("Error, player vyrn is out and can't perform the spell")
		return false

func _on_item_button_pressed() -> void:
	pass

func _on_flee_button_pressed() -> void:
	get_tree().change_scene_to_packed(load("res://scenes/game.tscn"))


# Enemy actions
func enemy_attack() -> void:
	enemy.perform_attack();
	#await get_tree().create_timer(1.0).timeout
	# Animations
	enemy.emit_signal("pass_turn")
	
func enemy_spell() -> bool:
	if (enemy.vyrn >= enemy_spell_1_cost):
		enemy.vyrn -= enemy_spell_1_cost
		enemy.perform_attack();
		enemy.perform_attack(); # Double attack, placeholder
		# Animations
		enemy.emit_signal("pass_turn")
		return true
	else:
		print("Error, enemy vyrn is out and can't perform the spell")
		return false
