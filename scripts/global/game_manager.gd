extends Node

## Memory variables
var last_enemy_sprite_state: Dictionary
var current_enemy: NodePath
var last_enemy1: NodePath
var last_enemy2: NodePath
var last_enemy3: NodePath
var is_last_enemy_died: bool
var enemies_died: int
var last_player_pos: Vector2
var player_going_to_old_scene: bool
var player_flee: bool
var current_level: int # 0 = Main Menu

## Player stats
@export var player_max_stamina := 50.0
@export var player_max_hp: int
@export var player_max_vyrn: int
@export var player_attack_damage: int
# Current player stats
var player_stamina: float
var player_hp: int
var player_vyrn: int

func _ready() -> void:
	# TODO: Remember player HP from a file
	init_player(50, 150, 50, 10) # Only first game or checkpoint

func init_player(_max_stamina: float, _max_hp: int, _max_vyrn: int, _attack_damage: int):
	player_max_stamina = _max_stamina
	player_max_hp = _max_hp
	player_max_vyrn = _max_vyrn
	player_stamina = player_max_stamina
	player_hp = player_max_hp
	player_vyrn = player_max_vyrn
	player_attack_damage = _attack_damage

func order_enemies_died() -> void:
	if last_enemy2 != null:
		last_enemy3 = last_enemy2
	if last_enemy1 != null:
		last_enemy2 = last_enemy1
	if current_enemy != null:
		last_enemy1 = current_enemy
