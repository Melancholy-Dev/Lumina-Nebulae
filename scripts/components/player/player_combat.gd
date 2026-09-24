class_name PlayerCombat extends BaseCombatEntity

# TODO: invulnerability and buff

# Nodes
@export var player_stats: PlayerStats
@onready var scene_manager: SceneManager = get_tree().get_first_node_in_group("scene_manager")

func _ready() -> void:
	init_from_stats()
	player_stats.hp_changed.connect(_on_hp_changed)
	player_stats.vyrn_changed.connect(_on_vyrn_changed)
	player_stats.attack_damage_changed.connect(_on_attack_damage_changed)
	player_stats.died.connect(_die)
	if scene_manager:
		scene_manager.game_started.connect(init_from_stats)

func init_from_stats() -> void:
	max_hp = player_stats.max_hp
	max_vyrn = player_stats.max_vyrn
	hp = player_stats.hp
	vyrn = player_stats.vyrn
	attack_damage = player_stats.attack_damage
	alive = true

func _on_hp_changed(current_hp: int, max_hp_val: int) -> void:
	hp = current_hp
	max_hp = max_hp_val
	damaged.emit(max_hp_val - current_hp)  # emit damaged with amount taken
	if hp <= 0:
		_die()

func _on_vyrn_changed(current_vyrn: int, max_vyrn_val: int) -> void:
	vyrn = current_vyrn
	max_vyrn = max_vyrn_val

func _on_attack_damage_changed(damage: int) -> void:
	attack_damage = damage

func receive_damage(amount: int) -> void:
	if not alive:
		return
	player_stats.take_damage(amount)

func heal(amount: int) -> void:
	if not alive:
		return
	player_stats.heal(amount)

func consume_vyrn(amount: int) -> bool:
	return player_stats.consume_vyrn(amount)

func perform_attack(target: Node = null) -> void:
	if not alive:
		return
	if target and target.has_method("receive_damage"):
		target.receive_damage(attack_damage)
