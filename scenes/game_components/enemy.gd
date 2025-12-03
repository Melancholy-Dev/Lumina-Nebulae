extends CharacterBody2D
class_name Enemy

# TODO: invulnerabilità e buff

# Nodes
@onready var player: CharacterBody2D = $"../Player"

# Stats
@export var max_hp: int = 100
@export var attack_damage: int = 10

# Current Status
var hp: int
var alive: bool = true

# Signals
signal damaged(amount: int, from)
signal died()
signal attacked(target)


func _ready() -> void:
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
		player.receive_damage(attack_damage, self)
		emit_signal("attacked", player)

func _die() -> void:
	alive = false
	velocity = Vector2.ZERO
	emit_signal("died")
	# animations
