class_name AnimationComponent extends Node

# Nodes
@export var mc: MovementComponent
@export var im: InputManager
@export var sprite: AnimatedSprite2D

func _ready() -> void:
	mc.is_walking.connect(_is_walking)
	mc.is_idle.connect(_is_idle)

func _is_walking() -> void:
	sprite.play("walking")
	sprite.speed_scale = mc.target_speed / mc.base_speed # Sync walk animation speed to movement speed
	if im.move_dir < 0:
		sprite.set_flip_h(true)
	else:
		sprite.set_flip_h(false)

func _is_idle() -> void:
	sprite.play("idle")
	sprite.speed_scale = 1.0
