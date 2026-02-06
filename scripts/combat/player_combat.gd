extends Node
class_name Player

# TODO: invulnerability and buff

# Nodes
@onready var enemy: Node = $"../Enemy"

# Stats
@export var max_hp: int = 100
@export var attack_damage: int = 10

# Current Status
var hp: int
var alive: bool = true

# Signals
signal damaged(amount: int)
signal pass_turn
signal died()

func _ready() -> void:
	hp = max_hp
	# Placeholer, player will remember the current HP in future

func receive_damage(amount: int) -> void:
	if not alive:
		return
	hp -= amount
	emit_signal("damaged", amount)
	if hp <= 0:
		_die()

func heal(amount: int) -> void:
	if not alive:
		return
	hp = hp + amount

func perform_attack() -> void:
	if not alive:
		return
	if enemy and enemy.has_method("receive_damage"):
		enemy.receive_damage(attack_damage)

func _die() -> void:
	alive = false
	emit_signal("died")
	# animations
