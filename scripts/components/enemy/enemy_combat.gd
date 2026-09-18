class_name EnemyCombat extends BaseCombatEntity

# TODO: invulnerability and buff

# Nodes
@export var enemy_stats: EnemyStats
@export var sprite: AnimatedSprite2D

func _ready() -> void:
	if enemy_stats:
		init_from_stats()
		enemy_stats.hp_changed.connect(_on_hp_changed)
		enemy_stats.vyrn_changed.connect(_on_vyrn_changed)
		enemy_stats.died.connect(_die)
		enemy_stats.state_changed.connect(_on_state_changed)

func init_from_stats() -> void:
	if not enemy_stats:
		return
	max_hp = enemy_stats.max_hp
	max_vyrn = enemy_stats.max_vyrn
	hp = enemy_stats.hp
	vyrn = enemy_stats.vyrn
	attack_damage = enemy_stats.attack_damage
	alive = true

func _on_hp_changed(current_hp: int, max_hp_val: int) -> void:
	hp = current_hp
	max_hp = max_hp_val
	damaged.emit(max_hp_val - current_hp)

func _on_vyrn_changed(current_vyrn: int, max_vyrn_val: int) -> void:
	vyrn = current_vyrn
	max_vyrn = max_vyrn_val

func _on_state_changed(state_name: String) -> void:
	# TODO State changed, trigger behavior changes
	# Behaviors = normal, aggressive, defensive, last-resort (retreat/auto-destruction)
	pass

func receive_damage(amount: int) -> void:
	if not alive or not enemy_stats:
		return
	enemy_stats.take_damage(amount)

func heal(amount: int) -> void:
	if not alive or not enemy_stats:
		return
	enemy_stats.heal(amount)

func consume_vyrn(amount: int) -> bool:
	if not enemy_stats:
		return false
	return enemy_stats.consume_vyrn(amount)

func perform_attack(target: Node = null) -> void:
	if not alive:
		return
	if target and target.has_method("receive_damage"):
		target.receive_damage(attack_damage)

func get_enemy_state() -> String:
	if enemy_stats:
		return enemy_stats.current_state
	return "Unknown"

func _die() -> void:
	super._die()
	owner.queue_free()
