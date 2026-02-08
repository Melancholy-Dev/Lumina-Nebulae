extends CanvasLayer

# Nodes
@onready var fps_label: Label = $FPS/MarginContainer/FPSLabel
@onready var hp_label: Label = $PlayerStats/Hp/MarginContainer/HpLabel
@onready var vyrn_label: Label = $PlayerStats/Vyrn/MarginContainer/VyrnLabel

func _ready() -> void:
	# get current hp and vyrn from the save file
	hp_label.text = "HP: " + str(GameManager.player_hp)
	vyrn_label.text = "Vyrn: " + str(GameManager.player_vyrn)

func _process(delta: float) -> void:
	var fps: int = round(Engine.get_frames_per_second())
	fps_label.text = "FPS: " + str(fps)
