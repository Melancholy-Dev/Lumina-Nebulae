class_name Interactable extends Node

# Signals
signal interacted(interactable: Interactable)

# Nodes
@onready var input_manager: InputManager = get_tree().get_first_node_in_group("input_manager")

# Variables
@export var spawn_point_id: int = 1
@export var type := &""
var can_interact := false
var holds_player := false # Keep interaction alive (closet)

func _ready() -> void:
	if input_manager:
		input_manager.interact_input.connect(_on_interact_input)

func _on_interact_input(pressed: bool) -> void:
	if pressed and can_interact:
		_interacted()

func _interacted() -> void:
	interacted.emit(self)
