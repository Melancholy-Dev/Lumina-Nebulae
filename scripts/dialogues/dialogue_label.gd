extends Label

# Nodes
@onready var dialogue_panel: PanelContainer = $"../.."

# Variables
@export var auto_hide_time := 3.0
var full_text: String = "Text"
var letter_interval: float = 0.1
var object_is_interactable: bool

var _index: int = 0
var _timer: Timer
var _state: String = "idle" # "typing", "waiting", "idle"

func _ready() -> void:
	text = ""
	_timer = Timer.new()
	_timer.one_shot = false
	add_child(_timer)
	if not _timer.is_connected("timeout", Callable(self, "_on_timer_timeout")):
		_timer.timeout.connect(_on_timer_timeout)

func _on_area_body_entered(_body: Node) -> void:
	dialogue_panel.visible = true
	_index = 0
	text = ""
	_state = "typing"
	_timer.stop()
	_timer.wait_time = letter_interval
	_timer.one_shot = false
	_timer.start()

func _on_area_body_exited(_body: Node) -> void:
	if object_is_interactable:
		dialogue_panel.visible = false
		_state = "idle"
		_timer.stop()
		_index = 0
		text = ""

func _on_timer_timeout() -> void:
	if _state == "typing":
		if _index < full_text.length():
			text += full_text[_index]
			_index += 1
		else:
			# Wait time after hide the panel
			_state = "waiting"
			_timer.stop()
			_timer.wait_time = auto_hide_time
			_timer.one_shot = true
			_timer.start()
	elif _state == "waiting":
		if object_is_interactable:
			_state = "waiting"
			_timer.stop()
			return
		dialogue_panel.visible = false
		_state = "idle"
		_timer.stop()
