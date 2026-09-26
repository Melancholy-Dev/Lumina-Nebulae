class_name MovementComponent extends Node

# Signals
signal is_walking
signal is_idle
signal run_changed(is_running: bool)
signal stamina_changed(current_stamina: float, max_stamina: float)

# Nodes
@export var im: InputManager
@export var body: CharacterBody2D
@export var player_stats: PlayerStats
@onready var animation_manager: AnimationManager = get_tree().get_first_node_in_group("animation_manager")

# Variables
const MOVE_EPS := 8.0 # Ignore tiny movements
const RUN_MULTIPLIER := 2.0
var base_speed := 50.0
var target_speed := 1.0

# Stamina settings
var stamina_consume_per_second: float = 20.0
var stamina_recover_per_second: float = 15.0
const STAMINA_RECHARGE_DELAY : float = 2.0

# State
var movement_enabled := true
var resting := false
var can_recover := false
var can_run := false
var is_running := false
var _time_idle := 0.0

func _ready() -> void:
	player_stats.stamina_changed.connect(_on_stamina_changed)
	stamina_changed.emit(player_stats.stamina, player_stats.max_stamina)
	if animation_manager:
		animation_manager.fade_in_started.connect(set_movement_disabled)
		animation_manager.fade_out_ended.connect(set_movement_enabled)

func _on_stamina_changed(current: float, max_val: float) -> void:
	stamina_changed.emit(current, max_val)

func set_movement_disabled(resting_state: bool = false) -> void:
	movement_enabled = false
	resting = resting_state
	body.velocity.x = 0
	is_idle.emit()

func set_movement_enabled() -> void:
	movement_enabled = true
	resting = false

func _physics_process(delta: float) -> void:
	if not movement_enabled:
		if resting:
			_stand_still(delta)
		body.move_and_slide()
		body.position = body.position.snapped(Vector2(1, 1))
		return

	## Running
	var _current_stamina = player_stats.stamina
	can_run = _current_stamina > 0.0
	var was_running = is_running
	is_running = im.run_pressed and can_run
	if is_running:
		if not player_stats.consume_stamina(stamina_consume_per_second * delta):
			is_running = false
	if is_running != was_running:
		run_changed.emit(is_running)

	## Walking
	if im.move_dir != 0:
		is_walking.emit()
		target_speed = base_speed * (RUN_MULTIPLIER if is_running else 1.0)
		body.velocity.x = im.move_dir * target_speed
		_time_idle = 0.0 # Disable stamina recovery
		can_recover = false

	## Idle
	else:
		is_idle.emit()
		body.velocity.x = move_toward(body.velocity.x, 0, base_speed)
		_stand_still(delta)

	body.move_and_slide()
	body.position = body.position.snapped(Vector2(1, 1)) # Pixel perfect snap

func _stand_still(delta: float) -> void:
	_time_idle += delta
	if _time_idle >= STAMINA_RECHARGE_DELAY:
		can_recover = true
	if can_recover:
		player_stats.recover_stamina(stamina_recover_per_second * delta)
