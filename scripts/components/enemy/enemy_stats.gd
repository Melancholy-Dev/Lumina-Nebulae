class_name EnemyStats extends Node

# Signals
signal hp_changed(current_hp: int, max_hp: int)
signal vyrn_changed(current_vyrn: int, max_vyrn: int)
signal died
signal state_changed(state_name: String)

# Stats
@export var max_hp: int = 100
@export var max_vyrn: int = 50
@export var attack_damage: int = 10

# State
@export var state_thresholds: Dictionary = {
	"Healthy": Vector2(76, 100),
	"Wounded": Vector2(51, 75),
	"Critical": Vector2(21, 50),
	"Broken": Vector2(0, 20)
}

# Current values
var hp: int = 100
var vyrn: int = 50
var current_state: String = "Healthy"

func _ready() -> void:
	hp = max_hp
	vyrn = max_vyrn
	_update_state()

func take_damage(amount: int) -> void:
	if hp <= 0:
		return
	hp = max(0, hp - amount)
	hp_changed.emit(hp, max_hp)
	_update_state()
	if hp <= 0:
		died.emit()

func heal(amount: int) -> void:
	if hp <= 0:
		return
	hp = min(max_hp, hp + amount)
	hp_changed.emit(hp, max_hp)
	_update_state()

func consume_vyrn(amount: int) -> bool:
	if vyrn >= amount:
		vyrn -= amount
		vyrn_changed.emit(vyrn, max_vyrn)
		return true
	return false

func restore_vyrn(amount: int) -> void:
	vyrn = min(max_vyrn, vyrn + amount)
	vyrn_changed.emit(vyrn, max_vyrn)

func _update_state() -> void:
	var hp_pct = float(hp) / float(max_hp) * 100.0
	var new_state = "Unknown"
	for state_name in state_thresholds.keys():
		var r = state_thresholds[state_name]
		if hp_pct >= r.x and hp_pct <= r.y:
			new_state = state_name
			break
	if new_state != current_state:
		current_state = new_state
		state_changed.emit(new_state)

func get_hp_percent() -> float:
	return float(hp) / float(max_hp)

func get_vyrn_percent() -> float:
	return float(vyrn) / float(max_vyrn)

func is_alive() -> bool:
	return hp > 0

func is_dead() -> bool:
	return hp <= 0
