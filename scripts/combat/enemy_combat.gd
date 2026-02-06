extends Node
class_name Enemy

# TODO: invulnerability and buff

# Nodes
@onready var player: Node = $"../Player"

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


func init(_max_hp: int, _attack_damage: int):
	max_hp = _max_hp
	attack_damage = _attack_damage
	hp = max_hp


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
	if player and player.has_method("receive_damage"):
		player.receive_damage(attack_damage)

func _die() -> void:
	alive = false
	emit_signal("died")
	# animations
