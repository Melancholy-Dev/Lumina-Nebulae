class_name CombatResult extends Control

# Signals
signal finished

# Nodes
@export var combat_system: CombatSystem
@export var result_label: Label
@export var animation_player: AnimationPlayer

func _ready() -> void:
	combat_system.combat_started.connect(_on_combat_started)
	combat_system.combat_resolved.connect(_on_combat_resolved)
	animation_player.animation_finished.connect(_on_animation_finished)
	_reset()

func _on_combat_started(_player_combat: Node, _enemy_combat: Node) -> void:
	_reset()

func _on_combat_resolved(victory: bool) -> void:
	if victory:
		result_label.text = "You won"
		animation_player.play("victory")
	else:
		result_label.text = "You lose"
		animation_player.play("defeat")

func _on_animation_finished(anim_name: StringName) -> void:
	match anim_name:
		&"RESET":
			pass
		&"victory", &"defeat":
			finished.emit()
		_:
			push_error("Animation does not exist: %s" % anim_name)

func _reset() -> void:
	animation_player.play(&"RESET")
