class_name PlayerStats extends Node

# Signals
signal hp_changed(current_hp: int, max_hp: int)
signal vyrn_changed(current_vyrn: int, max_vyrn: int)
signal stamina_changed(current_stamina: float, max_stamina: float)
signal attack_damage_changed(damage: int)
signal died

# Nodes
@onready var scene_manager: SceneManager = get_tree().get_first_node_in_group("scene_manager")

# Stats
@export var max_hp: int = 150
@export var max_vyrn: int = 50
@export var max_stamina: float = 50.0
@export var attack_damage: int = 10

# Current status
var hp: int = 150
var vyrn: int = 50
var stamina: float = 50.0

func _ready() -> void:
	reset()
	if scene_manager:
		scene_manager.game_started.connect(reset)

func reset() -> void:
	hp = max_hp
	vyrn = max_vyrn
	stamina = max_stamina
	hp_changed.emit(hp, max_hp)
	vyrn_changed.emit(vyrn, max_vyrn)
	stamina_changed.emit(stamina, max_stamina)

func take_damage(amount: int) -> void:
	if hp <= 0:
		return
	hp = max(0, hp - amount)
	hp_changed.emit(hp, max_hp)
	if hp <= 0:
		died.emit()

func heal(amount: int) -> void:
	if hp <= 0:
		return
	hp = min(max_hp, hp + amount)
	hp_changed.emit(hp, max_hp)

func consume_vyrn(amount: int) -> bool:
	if vyrn >= amount:
		vyrn -= amount
		vyrn_changed.emit(vyrn, max_vyrn)
		return true
	return false

func restore_vyrn(amount: int) -> void:
	vyrn = min(max_vyrn, vyrn + amount)
	vyrn_changed.emit(vyrn, max_vyrn)

func consume_stamina(amount: float) -> bool:
	if stamina >= amount:
		stamina = max(0.0, stamina - amount)
		stamina_changed.emit(stamina, max_stamina)
		return true
	return false

func recover_stamina(amount: float) -> void:
	stamina = min(max_stamina, stamina + amount)
	stamina_changed.emit(stamina, max_stamina)

func set_attack_damage(damage: int) -> void:
	attack_damage = damage
	attack_damage_changed.emit(damage)

func get_hp_percent() -> float:
	return float(hp) / float(max_hp)

func get_vyrn_percent() -> float:
	return float(vyrn) / float(max_vyrn)

func get_stamina_percent() -> float:
	return stamina / max_stamina

func is_alive() -> bool:
	return hp > 0

func is_dead() -> bool:
	return hp <= 0
