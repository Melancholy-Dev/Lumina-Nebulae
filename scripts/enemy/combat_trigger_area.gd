extends Area2D

# Variables
var enemy_name: NodePath

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		# Save current enemy path and sprite
		enemy_name = get_parent().get_path()
		GameManager.last_enemy = enemy_name
		var enemy_node = get_node_or_null(enemy_name)
		if enemy_node:
			var sprite: AnimatedSprite2D = enemy_node.get_node_or_null("Sprite")
			if sprite:
				GameManager.last_enemy_sprite_state = {
					"sprite_frames": sprite.sprite_frames, # o sprite.sprite_frames.duplicate(true) se modifichi
					"animation": sprite.animation,
					"frame": sprite.frame,
					"modulate": sprite.modulate
				}
			else:
				push_error("Cannot find enemy sprite")
		else:
			push_error("Cannot find enemy node")

		# Finds for event manager and connect the signal automatically
