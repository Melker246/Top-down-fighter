extends Node2D

const PLAYER1_PATH = preload("res://Scenes/player.tscn")
const PLAYER2_PATH = preload("res://Scenes/player2.tscn")
const BOT1_PATH = preload("res://Scenes/bot1.tscn")
const BOT2_PATH = preload("res://Scenes/bot2.tscn")

@onready var player1: CharacterBody2D = $Player
@onready var player2: CharacterBody2D = $Player2
@onready var bot1: CharacterBody2D = $bot1
@onready var bot2: CharacterBody2D = $bot2
@onready var blue_house: Node2D = $BlueHouse
@onready var yellow_house: Node2D = $YellowHouse
@onready var red_house: Node2D = $RedHouse
@onready var black_house: Node2D = $BlackHouse
@onready var round_interference: CanvasLayer = $Round_interference

var dead_players = 0
var player_chosing_upgrades = 0

var player1_health_upgrades = 0
var player1_attack_upgrades = 0
var player1_speed_upgrades = 0
var player1_team_upgrades = 0

var player2_health_upgrades = 0
var player2_attack_upgrades = 0
var player2_speed_upgrades = 0
var player2_team_upgrades = 0

var bot1_health_upgrades = 0
var bot1_attack_upgrades = 0
var bot1_speed_upgrades = 0
var bot1_team_upgrades = 0

var bot2_health_upgrades = 0
var bot2_attack_upgrades = 0
var bot2_speed_upgrades = 0
var bot2_team_upgrades = 0



func _ready() -> void:
	blue_house.blue()
	yellow_house.yellow()
	red_house.red()
	black_house.black()
	bot1.connect("bot1_dead", _on_bot1_dead)
	bot2.connect("bot2_dead", _on_bot2_dead)
	player1.connect("player1_dead", _on_player1_dead)
	player2.connect("player2_dead", _on_player2_dead)
	round_interference.connect("health_button_pressed", _health_button_pressed)
	round_interference.connect("attack_button_pressed", _attack_button_pressed)
	round_interference.connect("speed_button_pressed", _speed_button_pressed)
	round_interference.connect("team_button_pressed", _team_button_pressed)


func _physics_process(delta: float) -> void:
	if bot1 != null:
		if player1 != null:
			bot1.player1_pos = player1.position
		else:
			bot1.player1_pos = null
		if player2 != null:
			bot1.player2_pos = player2.position
		else:
			bot1.player2_pos = null
		if bot2 != null:
			bot1.bot2_pos = bot2.position
		else:
			bot1.bot2_pos = null
	if bot2 != null:
		if player1 != null:
			bot2.player1_pos = player1.position
		else:
			bot2.player1_pos = null
		if player2 != null:
			bot2.player2_pos = player2.position
		else:
			bot2.player2_pos = null
		if bot1 != null:
			bot2.bot1_pos = bot1.position
		else:
			bot2.bot1_pos = null

func _round_over():
	round_interference.show()
	player_chosing_upgrades = 1

func _start_new_round():
	player1 = PLAYER1_PATH.instantiate()
	player2 = PLAYER2_PATH.instantiate()
	bot1 = BOT1_PATH.instantiate()
	bot2 = BOT2_PATH.instantiate()

func _on_bot1_dead():
	bot1 = null
	dead_players += 1
	if dead_players >= 3:
		_round_over()

func _on_bot2_dead():
	bot2 = null
	dead_players += 1
	if dead_players >= 3:
		_round_over()

func _on_player1_dead():
	player1 = null
	dead_players += 1
	if dead_players >= 3:
		_round_over()

func _on_player2_dead():
	player2 = null
	dead_players += 1
	if dead_players >= 3:
		_round_over()

func _health_button_pressed():
	if player_chosing_upgrades == 1:
		player1_health_upgrades += 1
		player_chosing_upgrades += 1
	elif player_chosing_upgrades == 2:
		player2_health_upgrades += 1
		round_interference.hide()
		_start_new_round()

func _attack_button_pressed():
	if player_chosing_upgrades == 1:
		player1_attack_upgrades += 1
		player_chosing_upgrades += 1
	elif player_chosing_upgrades == 2:
		player2_attack_upgrades += 1
		round_interference.hide()
		_start_new_round()

func _speed_button_pressed():
	if player_chosing_upgrades == 1:
		player1_speed_upgrades += 1
		player_chosing_upgrades += 1
	elif player_chosing_upgrades == 2:
		player2_speed_upgrades += 1
		round_interference.hide()
		_start_new_round()

func _team_button_pressed():
	if player_chosing_upgrades == 1:
		player1_team_upgrades += 1
		player_chosing_upgrades += 1
	elif player_chosing_upgrades == 2:
		player2_team_upgrades += 1
		round_interference.hide()
		_start_new_round()
