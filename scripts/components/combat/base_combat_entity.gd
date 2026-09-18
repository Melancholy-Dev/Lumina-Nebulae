class_name BaseCombatEntity extends Node

# Stats (override)
var max_hp: int
var max_vyrn: int
var hp: int
var vyrn: int
var alive: bool = true
var attack_damage: int

# Signals
signal damaged(amount: int)
signal pass_turn
signal died

func receive_damage(amount: int) -> void:
	if not alive:
		return
	hp -= amount
	damaged.emit(amount)
	if hp <= 0:
		_die()

func heal(amount: int) -> void:
	if not alive:
		return
	hp = min(max_hp, hp + amount)

func consume_vyrn(amount: int) -> bool:
	if vyrn >= amount:
		vyrn -= amount
		return true
	return false

func restore_vyrn(amount: int) -> void:
	vyrn = min(max_vyrn, vyrn + amount)

func perform_attack(target: Node = null) -> void:
	if not alive:
		return
	if target and target.has_method("receive_damage"):
		target.receive_damage(attack_damage)
	else:
		push_error("perform_attack() requires a valid target with receive_damage method")

func _die() -> void:
	if not alive:
		return
	alive = false
	died.emit()
