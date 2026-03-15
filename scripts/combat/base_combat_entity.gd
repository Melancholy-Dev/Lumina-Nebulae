extends Node
class_name BaseCombatEntity

# Stats (overridable via export or direct assignment)
var max_hp: int
var max_vyrn: int
var hp: int
var vyrn: int
var alive: bool = true
var attack_damage: int

# Signals
signal damaged(amount: int)
signal pass_turn
signal died()

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
	hp = min(max_hp, hp + amount)

func perform_attack() -> void:
	if not alive:
		return
	push_error("perform_attack() must be overridden in subclass")

func _die() -> void:
	alive = false
	emit_signal("died")
