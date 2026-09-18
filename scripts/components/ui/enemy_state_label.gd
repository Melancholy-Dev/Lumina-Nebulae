class_name EnemyStateLabel extends Label

# Nodes
@export var enemy_stats: EnemyStats:
	set(value):
		enemy_stats = value
		if not enemy_stats:
			return
		text = "State: " + enemy_stats.current_state
		if not enemy_stats.state_changed.is_connected(_on_state_changed):
			enemy_stats.state_changed.connect(_on_state_changed)

func _on_state_changed(state_name: String) -> void:
	text = "State: " + state_name
