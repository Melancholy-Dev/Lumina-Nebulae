class_name Fps extends PanelContainer

# Nodes
@export var fps_label: Label

# Variables
var _fps_timer: Timer
const FPS_UPDATE_INTERVAL: float = 0.5

func _ready() -> void:
	_fps_timer = Timer.new()
	_fps_timer.wait_time = FPS_UPDATE_INTERVAL
	add_child(_fps_timer)
	_fps_timer.timeout.connect(_on_fps_timer_timeout)
	_fps_timer.start()

func _on_fps_timer_timeout() -> void:
	var fps: int = round(Engine.get_frames_per_second())
	fps_label.text = "FPS: " + str(fps)
