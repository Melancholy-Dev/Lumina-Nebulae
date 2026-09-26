class_name Closet extends Interactable

# Nodes
@onready var dialogue_area: DialogueArea = $DialogueArea

# Variables
var enter_text := "Hide (interact)"
var exit_text := "Exit (interact)"
var player_hidden := false

func _ready() -> void:
	super()
	dialogue_area.dialogue_text = enter_text

func _interacted() -> void:
	player_hidden = not player_hidden
	holds_player = player_hidden # Keep interaction alive
	if player_hidden:
		dialogue_area.dialogue_text = exit_text
	else:
		dialogue_area.dialogue_text = enter_text
	dialogue_area.show_dialogue()
	super()
