extends CharacterBody2D

# Nodes
@onready var sprite: AnimatedSprite2D = $Sprite
@onready var collision: CollisionPolygon2D = $Collision

# Variables
@export var speed := 50.0
@export var max_stamina := 50.0
var current_stamina: float
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
const RUN_MULTIPLIER := 2.0

# Stamina settings
@export var stamina_consume_per_second := 20.0
@export var stamina_recover_per_second := 15.0
const STAMINA_RECHARGE_DELAY := 2.0

# Internal state
var _is_running := false
var _time_idle := 0.0
var _can_recover := false

func _ready() -> void:
	current_stamina = max_stamina

func _physics_process(delta: float) -> void:
	# Gravity
	if not is_on_floor():
		velocity.y += gravity * delta

	# Horizontal movement
	var direction := Input.get_axis("move_left", "move_right")
	var wants_run := Input.is_action_pressed("run") and direction != 0

	# Stamina checks
	var can_run := (current_stamina > 0.0)
	_is_running = wants_run and can_run

	# Movement and animation
	if direction != 0:
		var target_speed = speed * (RUN_MULTIPLIER if _is_running else 1.0)
		velocity.x = direction * target_speed
		sprite.play("walking")
		sprite.speed_scale = target_speed / speed # Sync walk animation speed to movement speed
		if direction < 0:
			sprite.set_flip_h(true)
			collision.position = Vector2(-1, 0)
		else:
			sprite.set_flip_h(false)
			collision.position = Vector2(0, 0)
		_time_idle = 0.0 # Disable stamina recovery
		_can_recover = false
	else:
		velocity.x = move_toward(velocity.x, 0, speed)
		sprite.play("idle")
		sprite.speed_scale = 1.0
		# Recover stamina if idle
		_time_idle += delta
		if _time_idle >= STAMINA_RECHARGE_DELAY:
			_can_recover = true

	# Stamina management
	if _is_running:
		current_stamina = max(0.0, current_stamina - stamina_consume_per_second * delta)
		if current_stamina <= 0.0:
			_is_running = false
	else:
		if _can_recover and direction == 0:
			current_stamina = min(max_stamina, current_stamina + stamina_recover_per_second * delta)
	current_stamina = clamp(current_stamina, 0.0, max_stamina)

	move_and_slide()
	position = position.snapped(Vector2(1, 1)) # Pixel perfect snap
