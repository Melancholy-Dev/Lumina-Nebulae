extends Area2D

# Nodes
@onready var dialogue_label: Node = $"../../UI/DialoguePanel/MarginContainer/DialogueLabel"

# Variables
@export var dialogue_text: String

func _ready():
	if dialogue_label:
		body_entered.connect(Callable(self, "_on_area_body_entered"))
		body_entered.connect(dialogue_label._on_area_body_entered)

func _on_area_body_entered(_body: Node) -> void:
	dialogue_label.full_text = dialogue_text
