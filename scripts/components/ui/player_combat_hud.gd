class_name PlayerCombatHUD extends VBoxContainer

# Nodes
@export var hp_label: Label
@export var vyrn_label: Label
@export var player_stats: PlayerStats:
	set(value):
		player_stats = value
		if not player_stats:
			return
		hp_label.text = "HP: %d/%d" % [player_stats.hp, player_stats.max_hp]
		vyrn_label.text = "Vyrn: %d/%d" % [player_stats.vyrn, player_stats.max_vyrn]
		if not player_stats.hp_changed.is_connected(_on_hp_changed):
			player_stats.hp_changed.connect(_on_hp_changed)
		if not player_stats.vyrn_changed.is_connected(_on_vyrn_changed):
			player_stats.vyrn_changed.connect(_on_vyrn_changed)

func _on_hp_changed(current_hp: int, max_hp_val: int) -> void:
	hp_label.text = "HP: %d/%d" % [current_hp, max_hp_val]

func _on_vyrn_changed(current_vyrn: int, max_vyrn_val: int) -> void:
	vyrn_label.text = "Vyrn: %d/%d" % [current_vyrn, max_vyrn_val]
