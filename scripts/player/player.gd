extends CharacterBody2D

const SPEED = 50.0
const JUMP_VELOCITY = -200

var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
@onready var sprite: AnimatedSprite2D = $Sprite
@onready var collision: CollisionPolygon2D = $Collision

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
