extends CharacterBody2D

# Nodes
@onready var sprite: AnimatedSprite2D = $Sprite
@onready var collision: CollisionPolygon2D = $Collision

# Variables
@export var SPEED := 50.0
@export var SPRINT_MULTIPLIER := 2.0
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

func _physics_process(delta):
	# Gravity
	if not is_on_floor():
		velocity.y += gravity * delta

	# Horizontal movement
	var direction := Input.get_axis("move_left", "move_right")
	var sprinting := Input.is_action_pressed("run") and direction != 0
	
	if direction != 0:
		var target_speed = SPEED * (SPRINT_MULTIPLIER if sprinting else 1.0)
		velocity.x = direction * target_speed
		sprite.play("walking")
		sprite.speed_scale = target_speed / SPEED # Sync walk animation speed to movement speed
		if direction < 0:
			sprite.set_flip_h(true)
			collision.position = Vector2(-1, 0)
		else:
			sprite.set_flip_h(false)
			collision.position = Vector2(0, 0)
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		sprite.play("idle")
		sprite.speed_scale = 1.0

	move_and_slide()
	position = position.snapped(Vector2(1, 1)) # Pixel perfect snap
