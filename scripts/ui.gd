extends CanvasLayer

# Nodes
@onready var fps_label: Label = $FPS/MarginContainer/FPSLabel
@onready var hp_label: Label = $PlayerStats/Hp/MarginContainer/HpLabel
@onready var vyrn_label: Label = $PlayerStats/Vyrn/MarginContainer/VyrnLabel
@onready var stamina_label: Label = $PlayerStats/Stamina/MarginContainer/StaminaLabel
@onready var player: CharacterBody2D = $"../Player"

func _ready() -> void:
	# Get current hp and vyrn from the save file
	hp_label.text = "HP: " + str(GameManager.player_hp)
	vyrn_label.text = "Vyrn: " + str(GameManager.player_vyrn)

func _process(_delta: float) -> void:
	var fps: int = round(Engine.get_frames_per_second())
	fps_label.text = "FPS: " + str(fps)
	stamina_label.text = "Stamina: " + str(int(player.current_stamina))
