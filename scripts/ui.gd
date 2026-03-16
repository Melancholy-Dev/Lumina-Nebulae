extends CanvasLayer

# Nodes
@onready var fps_label: Label = $FPS/MarginContainer/FPSLabel
@onready var hp_label: Label = $PlayerStats/Hp/MarginContainer/HpLabel
@onready var vyrn_label: Label = $PlayerStats/Vyrn/MarginContainer/VyrnLabel
@onready var stamina_label: Label = $PlayerStats/Stamina/MarginContainer/StaminaLabel
@onready var player: CharacterBody2D = $"../Player"

# Timer for FPS updates
var _fps_timer: Timer
const FPS_UPDATE_INTERVAL: float = 0.5

func _ready() -> void:
	# Setup FPS timer
	_fps_timer = Timer.new()
	_fps_timer.wait_time = FPS_UPDATE_INTERVAL
	add_child(_fps_timer)
	_fps_timer.timeout.connect(_on_fps_timer_timeout)
	_fps_timer.start()
	
	# Get current hp and vyrn from the save file
	hp_label.text = "HP: " + str(GameManager.player_hp)
	vyrn_label.text = "Vyrn: " + str(GameManager.player_vyrn)
	
	# Connect to stamina signal
	if player.is_connected("stamina_changed", Callable(self, "_on_player_stamina_changed")):
		pass
	else:
		player.stamina_changed.connect(_on_player_stamina_changed)
	_on_player_stamina_changed(player.max_stamina)

func _on_fps_timer_timeout() -> void:
	var fps: int = round(Engine.get_frames_per_second())
	fps_label.text = "FPS: " + str(fps)

func _on_player_stamina_changed(stamina: float) -> void:
	stamina_label.text = "Stamina: " + str(roundi(stamina))
