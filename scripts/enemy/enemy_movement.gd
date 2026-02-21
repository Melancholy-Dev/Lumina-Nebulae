extends CharacterBody2D

# Nodes
@onready var sprite: AnimatedSprite2D = $Sprite
@onready var movement_range: Node2D = $MovementRange

# Variables
@export var patrol_distance: float = 0.0
@export var speed: float = 60.0
@export var start_direction: Vector2 = Vector2.RIGHT

# Current status
var origin_position: Vector2
var travel_direction: Vector2
var traveled: float = 0.0

func _ready() -> void:
	patrol_distance = movement_range.position.x
	origin_position = global_position
	travel_direction = start_direction.normalized()
	if abs(travel_direction.x) > 0.5:
		travel_direction = Vector2(sign(travel_direction.x), 0)
	elif abs(travel_direction.y) > 0.5:
		travel_direction = Vector2(0, sign(travel_direction.y))
	else:
		travel_direction = Vector2.RIGHT

func _physics_process(delta: float) -> void:
	var motion: Vector2 = travel_direction * speed * delta
	var collision = move_and_collide(motion)
	if collision:
		_on_hit_obstacle(collision)
	else:
		global_position = global_position.snapped(Vector2(1, 1)) # Pixel perfect
		traveled = (global_position - origin_position).length()
		var half = patrol_distance * 0.5
		var offset = (global_position - origin_position).dot(travel_direction)
		if offset > half:
			_flip_direction()
		elif offset < -half:
			_flip_direction()

func _on_hit_obstacle(collision: KinematicCollision2D) -> void:
	var n = collision.get_normal()
	if n.dot(travel_direction) < -0.1:
		_flip_direction()
	global_position = global_position.snapped(Vector2(1, 1)) # Pixel perfect
	global_position += n * collision.get_remainder().length()

func _flip_direction() -> void:
	sprite.flip_h = travel_direction.x < 0
	travel_direction = -travel_direction
