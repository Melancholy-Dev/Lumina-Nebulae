extends Area2D

# Variables
var enemy_name: NodePath

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		enemy_name = get_parent().get_path()
		GameManager.last_enemy_died = enemy_name
