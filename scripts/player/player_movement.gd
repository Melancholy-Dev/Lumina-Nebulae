extends CharacterBody2D

# Nodes
@onready var sprite: AnimatedSprite2D = $Sprite
@onready var collision: CollisionPolygon2D = $Collision
@onready var footstep_player: AudioStreamPlayer = $Footstep

# Variables
@export var speed := 50.0
var max_stamina := GameManager.player_max_stamina
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
const RUN_MULTIPLIER := 2.0

# Footstep timing
@export var base_step_interval := 0.45
@export var run_step_multiplier := 0.6
@export var run_pitch_multiplier := 1.25
var _step_timer := 0.0
var _was_moving := false
const MOVE_EPS := 8.0 # Ignore tiny movements

# Stamina settings
@export var stamina_consume_per_second := 20.0
@export var stamina_recover_per_second := 15.0
const STAMINA_RECHARGE_DELAY := 2.0

# Internal state
var _is_running := false
var _time_idle := 0.0
var _can_recover := false
var _last_stamina: float = 0.0

# Signals
signal stamina_changed(stamina: float)

func _play_footstep(running: bool) -> void:
	var pitch = (run_pitch_multiplier if running else 1.0)
	footstep_player.pitch_scale = pitch
	if footstep_player.playing:
		footstep_player.stop()
	footstep_player.play()
	_step_timer = 0.0

func _physics_process(delta: float) -> void:
	# Gravity
	if not is_on_floor():
		velocity.y += gravity * delta

	# Horizontal movement input
	var direction := Input.get_axis("move_left", "move_right")
	var wants_run := Input.is_action_pressed("run") and direction != 0

	# Stamina checks
	var can_run := (GameManager.player_stamina > 0.0)
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
		# Reset footstep timer when stopped
		_step_timer = 0.0

	# Determine actual movement (use velocity to avoid tiny input glitches)
	var is_moving = abs(velocity.x) > MOVE_EPS and is_on_floor()

	# Immediate first step on start moving
	if is_moving and not _was_moving:
		_play_footstep(_is_running)

	# Footstep continuous handling when moving
	if is_moving:
		var interval = base_step_interval * (run_step_multiplier if _is_running else 1.0)
		_step_timer += delta
		if _step_timer >= interval:
			_play_footstep(_is_running)
	_was_moving = is_moving

	# Stamina management
	if _is_running:
		GameManager.player_stamina = max(0.0, GameManager.player_stamina - stamina_consume_per_second * delta)
		if GameManager.player_stamina <= 0.0:
			_is_running = false
	else:
		if _can_recover and direction == 0:
			GameManager.player_stamina = min(max_stamina, GameManager.player_stamina + stamina_recover_per_second * delta)
	GameManager.player_stamina = clamp(GameManager.player_stamina, 0.0, max_stamina)
	
	# Emit signal only if stamina changed significantly to avoid excessive signal emissions
	if abs(GameManager.player_stamina - _last_stamina) > 0.1:
		_last_stamina = GameManager.player_stamina
		emit_signal("stamina_changed", GameManager.player_stamina)

	move_and_slide()
	position = position.snapped(Vector2(1, 1)) # Pixel perfect snap
