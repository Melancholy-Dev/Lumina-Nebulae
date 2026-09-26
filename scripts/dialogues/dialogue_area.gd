class_name DialogueArea extends Area2D

# Nodes
@onready var dialogue_label: Label

# Variables
@export var dialogue_text: String
var player_inside: bool

func _ready():
	dialogue_label = find_node_by_name(get_tree().current_scene, "DialogueLabel")
	body_entered.connect(_on_area_body_entered)
	body_exited.connect(_on_area_body_exited)

func _on_area_body_entered(body: Node) -> void:
	if body.is_in_group("player"):
		player_inside = true
		var parent_interactable = get_parent()
		if parent_interactable is Interactable:
			parent_interactable.can_interact = true
		show_dialogue()

func _on_area_body_exited(body: Node) -> void:
	if body.is_in_group("player"):
		if _interactable_holds_player():
			return
		player_inside = false
		var parent_interactable = get_parent()
		if parent_interactable is Interactable:
			parent_interactable.can_interact = false
		if dialogue_label:
			dialogue_label._on_area_body_exited(body)
		else:
			push_error("Node 'dialogue_label' not found")

func show_dialogue() -> void:
	if dialogue_label:
		dialogue_label.object_is_interactable = get_parent() is Interactable
		dialogue_label.show_message(dialogue_text)
	else:
		push_error("Node 'dialogue_label' not found")

func _interactable_holds_player() -> bool:
	var parent_interactable := get_parent()
	if parent_interactable is Interactable:
		return parent_interactable.holds_player
	return false

func find_node_by_name(root: Node, target_name: String) -> Node:
	if root.name == target_name:
		return root
	for child in root.get_children():
		var found = find_node_by_name(child, target_name)
		if found:
			return found
	return null
