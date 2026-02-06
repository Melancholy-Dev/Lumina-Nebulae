extends Node

# Nodes
@onready var buttons_ui: Node = $"../Buttons"
@onready var player: Node = $"../Player"
@onready var enemy: Node = $"../Enemy"

# Variables
var player_turn: bool = true
@onready var buttons: Array[Button] = []



#### Management functions
func _ready() -> void:
	enemy.init(100, 10) # Max_HP, Damage
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
		# enemy turn, random action based on the skills
		enemy_attack()
	# Player can not perform actions until player_turn = true



#### Signals
# Enemy signal
func _on_enemy_pass_turn() -> void:
	player_turn = true
	buttons[0].grab_focus()

func _on_enemy_damaged(amount: int) -> void:
	print("Enemy HP: " + str(enemy.hp))

func _on_enemy_died() -> void:
	print("Enemy Died")
	#enemy.queue_free()
	# TODO Block the combat to prevent game crash
	get_tree().change_scene_to_packed(load("res://scenes/game.tscn"))


# Player signals
func _on_player_pass_turn() -> void:
	player_turn = false

func _on_player_damaged(amount: int) -> void:
	print("Player HP: " + str(player.hp))

func _on_player_died() -> void:
	print("Player Died")



#### Actions
# Player actions
func _on_fight_button_pressed() -> void:
	enemy.receive_damage(10)
	player.emit_signal("pass_turn")

func _on_spell_button_pressed() -> void:
	enemy.receive_damage(20)
	player.emit_signal("pass_turn")
	# TODO Implements Vyrn system

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
