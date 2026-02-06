extends CharacterBody2D

const SPEED = 50.0
const JUMP_VELOCITY = -200

var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
@onready var sprite: AnimatedSprite2D = $Sprite
@onready var collision: CollisionPolygon2D = $Collision

# CRT Shader (move this to a game manager)
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

#TODO: Move this to a game manager
func _on_combat_area_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player"):
		var mat = cr.material
		if mat and mat is ShaderMaterial: # Placeholder CRT effect
			var start_val : float = 0.06
			var end_val : float = 1
			var duration : float = 4
			
			# Animation
			mat.set_shader_parameter("static_noise_intensity", start_val)
			var tween := create_tween()
			tween.tween_property(mat, "shader_parameter/static_noise_intensity", end_val, duration).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
			await tween.finished

			# Loading combat scene
			# TODO use the same CRT shader and do a fade-out in the combat scene
			get_tree().change_scene_to_packed(load("res://scenes/combat.tscn"))
