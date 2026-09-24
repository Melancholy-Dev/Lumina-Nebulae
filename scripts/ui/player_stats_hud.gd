class_name PlayerStatsHUD extends VBoxContainer

# Nodes
@export var hp_label: Label
@export var vyrn_label: Label
@export var stamina_label: Label
@export var player_stats: Node  # PlayerStats component

func _ready() -> void:
	if not player_stats:
		return
	
	# Get initial values
	hp_label.text = "HP: %d/%d" % [player_stats.hp, player_stats.max_hp]
	vyrn_label.text = "Vyrn: %d/%d" % [player_stats.vyrn, player_stats.max_vyrn]
	
	# Connect to signals
	player_stats.hp_changed.connect(_on_hp_changed)
	player_stats.vyrn_changed.connect(_on_vyrn_changed)
	player_stats.stamina_changed.connect(_on_stamina_changed)

func _on_hp_changed(current_hp: int, max_hp: int) -> void:
	hp_label.text = "HP: %d/%d" % [current_hp, max_hp]

func _on_vyrn_changed(current_vyrn: int, max_vyrn: int) -> void:
	vyrn_label.text = "Vyrn: %d/%d" % [current_vyrn, max_vyrn]

func _on_stamina_changed(current_stamina: float, max_stamina: float) -> void:
	stamina_label.text = "Stamina: %d/%d" % [roundi(current_stamina), roundi(max_stamina)]
