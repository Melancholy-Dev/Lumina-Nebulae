extends Node
class_name Player

# TODO: invulnerability and buff

# Nodes
@onready var enemy: Node = $"../Enemy"

# Current Stats
var alive: bool = true

# Signals
signal damaged(amount: int)
signal pass_turn
signal died()

func _ready() -> void:
	init()

func init() -> void:
	GameManager.player_hp = GameManager.player_max_hp
	# Placeholer, player will remember the current HP in future

func receive_damage(amount: int) -> void:
	if not alive:
		return
	GameManager.player_hp -= amount
	emit_signal("damaged", amount)
	if GameManager.player_hp <= 0:
		_die()

func heal(amount: int) -> void:
	if not alive:
		return
	GameManager.player_hp = GameManager.player_hp + amount

func perform_attack() -> void:
	if not alive:
		return
	if enemy and enemy.has_method("receive_damage"):
		enemy.receive_damage(GameManager.player_attack_damage)

func _die() -> void:
	alive = false
	emit_signal("died")
	# animations
