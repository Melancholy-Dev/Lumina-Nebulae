class_name HidingComponent extends Node

# Nodes
@export var body: CharacterBody2D
@export var sprite: AnimatedSprite2D
@export var collision: CollisionPolygon2D
@export var movement_component: MovementComponent
@onready var scene_manager: SceneManager = get_tree().get_first_node_in_group("scene_manager")

# Variables
var is_hidden := false

func _ready() -> void:
	if scene_manager:
		scene_manager.player_hiding_requested.connect(set_hidden)
		scene_manager.game_started.connect(_on_game_started)

func _on_game_started() -> void:
	set_hidden(false)

func _physics_process(_delta: float) -> void:
	if is_hidden and movement_component.movement_enabled:
		movement_component.set_movement_disabled(true)

func set_hidden(hidden: bool, hiding_spot: Node2D = null) -> void:
	if is_hidden == hidden:
		return
	is_hidden = hidden
	sprite.visible = not hidden
	collision.disabled = hidden
	if hidden:
		movement_component.set_movement_disabled(true) # Keep recovering stamina
		if hiding_spot:
			body.global_position = Vector2(hiding_spot.global_position.x, body.global_position.y)
	else:
		movement_component.set_movement_enabled()
