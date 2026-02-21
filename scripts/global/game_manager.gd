extends Node

## Memory variables
var last_enemy_sprite_state: Dictionary
var current_enemy: NodePath
var last_enemy: NodePath
var last_enemy2: NodePath
var last_enemy3: NodePath
var is_last_enemy_died: bool
var enemies_died: int
var last_player_pos: Vector2
var player_flee: bool

## Player stats
@export var player_max_hp: int
@export var player_max_vyrn: int
@export var player_attack_damage: int
# Player current stats
var player_hp: int
var player_vyrn: int

func _ready() -> void:
	# TODO: Remember player HP from a file
	init_player(150, 50, 10) # Only first game or checkpoint

func init_player(_max_hp: int, _max_vyrn: int, _attack_damage: int):
	player_max_hp = _max_hp
	player_max_vyrn = _max_vyrn
	player_hp = player_max_hp
	player_vyrn = player_max_vyrn
	player_attack_damage = _attack_damage

func order_enemies_died() -> void:
	if last_enemy2 != null:
		last_enemy3 = last_enemy2
	if last_enemy != null:
		last_enemy2 = last_enemy
	if current_enemy != null:
		last_enemy = current_enemy
