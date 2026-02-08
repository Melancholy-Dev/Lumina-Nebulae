extends Node
class_name Enemy

# TODO: invulnerability and buff

# Nodes
@onready var player: Node = $"../Player"

# Stats
@export var max_hp: int = 100
@export var max_vyrn: int = 50
@export var attack_damage: int = 10
@export var enemy_states := {
	"Healthy": { # Behaviors = normal, aggressive, defensive, last-resort (retreat/auto-destruction)
		"hp_range": Vector2(76, 100),
		"behavior": "Normal"
	},
	"Wounded": {
		"hp_range": Vector2(51, 75),
		"behavior": "Normal"
	},
	"Critical": {
		"hp_range": Vector2(21, 50),
		"behavior": "Normal"
	},
	"Broken": {
		"hp_range": Vector2(0, 20),
		"behavior": "Normal"
	}
}

# Current Status
var hp: int
var vyrn: int
var alive: bool = true

# Signals
signal damaged(amount: int)
signal pass_turn
signal died()


func init(_max_hp: int, _max_vyrn: int, _attack_damage: int):
	max_hp = _max_hp
	max_vyrn = _max_vyrn
	hp = max_hp
	vyrn = max_vyrn
	attack_damage = _attack_damage

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

func get_enemy_state() -> String:
	var hp_pct: float = clamp(float(hp) / float(max_hp) * 100.0, 0.0, 100.0)
	for state_name in enemy_states.keys():
		var r = enemy_states[state_name]["hp_range"]
		if hp_pct >= r.x and hp_pct <= r.y:
			return state_name
	return "Unknown"

func _die() -> void:
	alive = false
	emit_signal("died")
	# animations
