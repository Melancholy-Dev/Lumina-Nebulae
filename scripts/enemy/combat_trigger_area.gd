extends Area2D

# Nodes
@onready var event_manager: Node = $"../../SceneManagers/EventManager"

# Variables
var enemy_name: NodePath

func _ready() -> void:
	# Connect signals
	body_entered.connect(Callable(self, "_on_body_entered"))
	body_entered.connect(event_manager._on_combat_trigger_area_body_entered)
	body_exited.connect(event_manager._on_combat_trigger_area_body_exited)

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		# Save current enemy path and sprite
		enemy_name = get_parent().get_path()
		GameManager.current_enemy = enemy_name
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
