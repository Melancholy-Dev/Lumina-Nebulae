extends CharacterBody2D

const SPEED = 50.0
const JUMP_VELOCITY = -200

var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
@onready var sprite: AnimatedSprite2D = $Sprite
@onready var collision: CollisionPolygon2D = $Collision

# CRT Shader
@onready var cr: ColorRect = $"../CanvasLayer/CRT"

func _physics_process(delta):
	
	# Gravity
	if not is_on_floor():
		velocity.y += gravity * delta

	# Jumps
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY
		sprite.play("idle") # Jump anim

	# Horizontal movement
	var direction = Input.get_axis("ui_left", "ui_right")
	if direction != 0:
		velocity.x = direction * SPEED
		sprite.play("walking")
		if direction < 0:
			sprite.set_flip_h(true)
			collision.position = Vector2(-1, 0)
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		sprite.play("idle")
		if direction >= 0:
			sprite.set_flip_h(false)
			collision.position = Vector2(0, 0)

	move_and_slide()
	position = position.snapped(Vector2(1, 1)) # Pixel perfect


func _on_combat_area_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player"):
		var mat = cr.material
		if mat and mat is ShaderMaterial: # Placeholder CRT effect
			mat.set_shader_parameter("static_noise_intensity", 0.2)
			await get_tree().create_timer(1).timeout
			mat.set_shader_parameter("static_noise_intensity", 0.4)
			await get_tree().create_timer(1).timeout
			mat.set_shader_parameter("static_noise_intensity", 0.75)
			await get_tree().create_timer(1).timeout
			mat.set_shader_parameter("static_noise_intensity", 1.0)
			await get_tree().create_timer(1).timeout
			
			# Loading combat scene
			var scene = preload("res://scenes/combat.tscn")
			var inst = scene.instantiate()
			add_child(inst)
