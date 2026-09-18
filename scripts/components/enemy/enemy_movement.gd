extends Node

# Nodes
@export var body: CharacterBody2D
@export var sprite: AnimatedSprite2D
@export var movement_range: Node2D
@export var trigger_area: CombatTriggerArea

# Variables
@export var speed: float = 60.0
@export var chase_speed: float = 80.0
@export var start_direction: Vector2 = Vector2.RIGHT
@export var min_state_time: float = 1.0
@export var max_state_time: float = 3.0
@export var chase_stop_distance: float = 4.0

# Current status
enum PatrolState { IDLE, WALK }
var patrol_distance: float = 0.0
var origin_position: Vector2
var is_following: bool = false
var patrol_state: PatrolState = PatrolState.IDLE
var _patrol_axis: Vector2 = Vector2.RIGHT
var _direction: int = 1
var _state_timer: float = 0.0

func _ready() -> void:
	patrol_distance = movement_range.position.length()
	origin_position = body.global_position
	_patrol_axis = _axis_of(start_direction)
	if trigger_area:
		trigger_area.player_entered.connect(_on_player_entered)
		trigger_area.player_exited.connect(_on_player_exited)
	_pick_random_state()

func _on_player_entered(_enemy_node: Node) -> void:
	is_following = true

func _on_player_exited(_enemy_node: Node) -> void:
	is_following = false
	_pick_random_state()

func _physics_process(delta: float) -> void:
	if is_following:
		_chase(delta)
	else:
		_patrol(delta)

func _chase(delta: float) -> void:
	var player: Node2D = get_tree().get_first_node_in_group("player")
	if player == null:
		is_following = false
		_pick_random_state()
		return
	var offset: float = (player.global_position - body.global_position).dot(_patrol_axis)
	if absf(offset) <= chase_stop_distance:
		_set_walking(false)
		return
	_direction = int(signf(offset))
	_set_walking(true)
	_move(_patrol_axis * float(_direction) * chase_speed * delta)

func _patrol(delta: float) -> void:
	_state_timer -= delta
	if _state_timer <= 0.0:
		_pick_random_state()
	if patrol_state == PatrolState.IDLE:
		_set_walking(false)
		return
	_set_walking(true)
	if not _move(_patrol_axis * float(_direction) * speed * delta):
		_reverse() # Collisions
		return
	_keep_in_range()

func _move(motion: Vector2) -> bool:
	var collided: bool = body.move_and_collide(motion) != null
	body.global_position = body.global_position.snapped(Vector2(1, 1)) # Pixel perfect
	return not collided

func _pick_random_state() -> void:
	_state_timer = randf_range(min_state_time, max_state_time)
	match randi() % 3:
		0:
			patrol_state = PatrolState.IDLE
		1:
			patrol_state = PatrolState.WALK
			_direction = 1
		_:
			patrol_state = PatrolState.WALK
			_direction = -1

func _keep_in_range() -> void:
	var half: float = patrol_distance * 0.5
	var offset: float = (body.global_position - origin_position).dot(_patrol_axis)
	if (offset >= half and _direction > 0) or (offset <= -half and _direction < 0):
		_reverse()

func _reverse() -> void:
	_direction = -_direction
	_state_timer = randf_range(min_state_time, max_state_time)
	_set_walking(true)

func _set_walking(walking: bool) -> void:
	sprite.flip_h = _direction < 0
	if walking:
		sprite.play()
	else:
		sprite.pause()

func _axis_of(direction: Vector2) -> Vector2:
	if absf(direction.x) > absf(direction.y):
		return Vector2(signf(direction.x), 0.0)
	if direction.y != 0.0:
		return Vector2(0.0, signf(direction.y))
	return Vector2.RIGHT
