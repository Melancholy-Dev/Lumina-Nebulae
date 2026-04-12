extends BaseCombatEntity
class_name Player

# TODO: invulnerability and buff

# Nodes
@onready var enemy: Node = $"../Enemy"

func _ready() -> void:
	init()

func init() -> void:
	hp = GameManager.player_hp
	max_hp = GameManager.player_max_hp
	vyrn = GameManager.player_vyrn
	max_vyrn = GameManager.player_max_vyrn
	attack_damage = GameManager.player_attack_damage
	# Placeholer, player will remember the current HP in future

func receive_damage(amount: int) -> void:
	if not alive:
		return
	hp -= amount
	GameManager.player_hp = hp
	emit_signal("damaged", amount)
	if hp <= 0:
		_die()

func heal(amount: int) -> void:
	if not alive:
		return
	hp = min(max_hp, hp + amount)
	GameManager.player_hp = hp

func perform_attack() -> void:
	if not alive:
		return
	if enemy and enemy.has_method("receive_damage"):
		enemy.receive_damage(attack_damage)
