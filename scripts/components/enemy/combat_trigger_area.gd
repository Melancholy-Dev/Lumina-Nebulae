class_name CombatTriggerArea extends Area2D

# Signals
signal player_entered(enemy_node: Node)
signal player_exited(enemy_node: Node)

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		player_entered.emit(get_parent())

func _on_body_exited(body: Node2D) -> void:
	if body.is_in_group("player"):
		player_exited.emit(get_parent())
