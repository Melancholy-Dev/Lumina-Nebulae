class_name PlayerStats extends Node

# Signals
signal hp_changed(current_hp: int, max_hp: int)
signal vyrn_changed(current_vyrn: int, max_vyrn: int)
signal stamina_changed(current_stamina: float, max_stamina: float)
signal attack_damage_changed(damage: int)
signal died

# Nodes
@onready var scene_manager: SceneManager = get_tree().get_first_node_in_group("scene_manager")
@onready var save_manager: SaveManager = get_tree().get_first_node_in_group("save_manager")

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
	if save_manager:
		save_manager.save_loaded.connect(_on_save_loaded)

func _on_save_loaded(data: Dictionary) -> void:
	load_from(data.get("stats", {}))

func reset() -> void:
	hp = max_hp
	vyrn = max_vyrn
	stamina = max_stamina
	hp_changed.emit(hp, max_hp)
	vyrn_changed.emit(vyrn, max_vyrn)
	stamina_changed.emit(stamina, max_stamina)

func load_from(data: Dictionary) -> void:
	# Clamp everything into a playable state
	max_hp = maxi(1, int(data.get("max_hp", max_hp)))
	max_vyrn = maxi(1, int(data.get("max_vyrn", max_vyrn)))
	max_stamina = maxf(1.0, float(data.get("max_stamina", max_stamina)))
	attack_damage = maxi(0, int(data.get("attack_damage", attack_damage)))
	hp = clampi(int(data.get("hp", max_hp)), 1, max_hp)
	vyrn = clampi(int(data.get("vyrn", max_vyrn)), 0, max_vyrn)
	stamina = clampf(float(data.get("stamina", max_stamina)), 0.0, max_stamina)
	hp_changed.emit(hp, max_hp)
	vyrn_changed.emit(vyrn, max_vyrn)
	stamina_changed.emit(stamina, max_stamina)
	attack_damage_changed.emit(attack_damage)

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
