extends Area2D

# Nodes
@onready var dialogue_label: Node = $"../../UI/DialoguePanel/MarginContainer/DialogueLabel"
@onready var stairs_area: Node = $"../../StairsArea"

# Variables
@export var dialogue_text: String
@export var interactable: bool
@export var object_type: String
var _player_inside: bool

func _ready():
	if not is_connected("body_entered", Callable(self, "_on_area_body_entered")):
		connect("body_entered", Callable(self, "_on_area_body_entered"))
	if not is_connected("body_exited", Callable(self, "_on_area_body_exited")):
		connect("body_exited", Callable(self, "_on_area_body_exited"))
	if dialogue_label and dialogue_label.has_method("_on_area_body_entered"):
		connect("body_entered", Callable(dialogue_label, "_on_area_body_entered"))
	if dialogue_label and dialogue_label.has_method("_on_area_body_exited"):
		connect("body_exited", Callable(dialogue_label, "_on_area_body_exited"))

func _on_area_body_entered(body: Node) -> void:
	if body.is_in_group("player"):
		_player_inside = true
		if dialogue_label:
			dialogue_label.full_text = dialogue_text
			if interactable:
				dialogue_label.object_is_interactable = true
			else:
				dialogue_label.object_is_interactable = false
		else:
			push_error("Node 'dialogue_label' not found")

func _on_area_body_exited(body: Node) -> void:
	if body.is_in_group("player"):
		_player_inside = false

func _process(_delta: float) -> void:
	if interactable and _player_inside and Input.is_action_just_pressed("interact"):
		match object_type:
			"stairs_down":
				stairs_area.player_go_up()
			"stairs_up":
				stairs_area.player_go_down()
			_:
				print("Interactable object is not configurated")
