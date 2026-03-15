extends Area2D

# Object type enum
enum ObjectType { STAIRS_DOWN, STAIRS_UP, STAIRS_NEW_SCENE, STAIRS_OLD_SCENE }

# Nodes
@onready var dialogue_label: Node = $"../../UI/DialoguePanel/MarginContainer/DialogueLabel"
@onready var stairs_area: Node = $"../../StairsArea1"

# Variables
@export var dialogue_text: String
@export var interactable: bool
@export var object_type: ObjectType
var _player_inside: bool

func _ready():
	# Connect area signals only once, avoiding is_connected check
	body_entered.connect(_on_area_body_entered)
	body_exited.connect(_on_area_body_exited)

func _on_area_body_entered(body: Node) -> void:
	if body.is_in_group("player"):
		_player_inside = true
		if dialogue_label:
			dialogue_label.full_text = dialogue_text
			dialogue_label.object_is_interactable = interactable
			dialogue_label._on_area_body_entered(body)
		else:
			push_error("Node 'dialogue_label' not found")

func _on_area_body_exited(body: Node) -> void:
	if body.is_in_group("player"):
		_player_inside = false
		if dialogue_label:
			dialogue_label._on_area_body_exited(body)

func _process(_delta: float) -> void:
	if interactable and _player_inside and Input.is_action_just_pressed("interact"):
		match object_type:
			ObjectType.STAIRS_DOWN:
				stairs_area.go_up()
			ObjectType.STAIRS_UP:
				stairs_area.go_down()
			ObjectType.STAIRS_NEW_SCENE:
				stairs_area.new_scene()
			ObjectType.STAIRS_OLD_SCENE:
				stairs_area.old_scene()
			_:
				print("Interactable object is not configurated")
