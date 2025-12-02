extends Node2D

const ARCHER_TOWER_SCENE = preload("res://Scenes/archer_tower.tscn")

@onready var player1: CharacterBody2D = $Player
@onready var player2: CharacterBody2D = $Player2
@onready var bot1: CharacterBody2D = $bot1
@onready var bot2: CharacterBody2D = $bot2
@onready var blue_house: StaticBody2D = $BlueHouse
@onready var yellow_house: StaticBody2D = $YellowHouse
@onready var red_house: StaticBody2D = $RedHouse
@onready var black_house: StaticBody2D = $BlackHouse
@onready var round_interference: CanvasLayer = $Round_interference

var blue_tower = null
var yellow_tower = null
var black_tower = null
var red_tower = null

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
	blue_house.connect("dead", _on_house_dead)
	yellow_house.connect("dead", _on_house_dead)
	red_house.connect("dead", _on_house_dead)
	black_house.connect("dead", _on_house_dead)
	bot1.connect("bot1_dead", _on_bot1_dead)
	bot2.connect("bot2_dead", _on_bot2_dead)
	player1.connect("player1_dead", _on_player1_dead)
	player2.connect("player2_dead", _on_player2_dead)
	round_interference.connect("health_button_pressed", _health_button_pressed)
	round_interference.connect("attack_button_pressed", _attack_button_pressed)
	round_interference.connect("speed_button_pressed", _speed_button_pressed)
	round_interference.connect("team_button_pressed", _team_button_pressed)


func _physics_process(delta: float) -> void:
	if player1.global_position != Vector2(-1000,-1000):
		bot1.player1_pos = player1.position
		bot2.player1_pos = player1.position
	else:
		bot1.player1_pos = null
		bot2.player1_pos = null
	if player2.global_position != Vector2(-1000,-2000):
		bot1.player2_pos = player2.position
		bot2.player2_pos = player2.position
	else:
		bot1.player2_pos = null
		bot2.player2_pos = null
	if bot2.global_position != Vector2(-2000,-1000):
		bot1.bot2_pos = bot2.position
	else:
		bot1.bot2_pos = null
	if bot1.global_position != Vector2(-2000,-2000):
		bot2.bot1_pos = bot1.position
	else:
		bot2.bot1_pos = null


func _round_over():
	round_interference.show()
	player_chosing_upgrades = 1
	var random_bot1_upgrade = randi_range(1,4)
	if random_bot1_upgrade == 1:
		bot1_health_upgrades += 1
	elif random_bot1_upgrade == 2:
		bot1_attack_upgrades += 1
	elif random_bot1_upgrade == 3:
		bot1_speed_upgrades += 1
	else:
		bot1_team_upgrades += 1
	var random_bot2_upgrade = randi_range(1,4)
	if random_bot2_upgrade == 1:
		bot2_health_upgrades += 1
	elif random_bot2_upgrade == 2:
		bot2_attack_upgrades += 1
	elif random_bot2_upgrade == 3:
		bot2_speed_upgrades += 1
	else:
		bot2_team_upgrades += 1

func _start_new_round():
	_reset_upgrades(player1)
	_reset_upgrades(player2)
	_reset_upgrades(bot1)
	_reset_upgrades(bot2)
	blue_house.rebuild()
	yellow_house.rebuild()
	black_house.rebuild()
	red_house.rebuild()
	player1.global_position = blue_house.global_position
	player2.global_position = yellow_house.global_position
	bot1.global_position = black_house.global_position
	bot2.global_position = red_house.global_position
	player1.dead = false
	player2.dead = false
	bot1.dead = false
	bot2.dead = false
	player1.enter_idle_state()
	player2.enter_idle_state()
	bot1.enter_idle_state()
	bot2.enter_idle_state()
	dead_players = 0
	_add_uppgrades()

func _reset_upgrades(player):
	player.hp = 100
	player.damage = 50
	player.speed = 1

func _add_uppgrades():
	if player1_health_upgrades >= 1:
		player1.hp *= 1.5
		if player1_health_upgrades >= 2:
			player1.hp *= 1.5 ** (player1_health_upgrades - 1)
	if player1_attack_upgrades >= 1:
		player1.damage *= 1.5
		if player1_attack_upgrades >= 2:
			player1.damage *= 1.5 ** (player1_attack_upgrades - 1)
	if player1_speed_upgrades >= 1:
		player1.speed *= 1.2
		if player1_speed_upgrades >= 2:
			player1.speed *= 1.2 ** (player1_speed_upgrades - 1)
	if player1_team_upgrades >= 1:
		blue_tower = ARCHER_TOWER_SCENE.instantiate()
		add_child(blue_tower)
		blue_tower.connect("dead", _on_house_dead)
		blue_tower.blue()
		blue_house.hide()
		blue_tower.position = blue_house.global_position
	
	if player2_health_upgrades >= 1:
		player2.hp *= 1.5
		if player2_health_upgrades >= 2:
			player2.hp *= 1.5 ** (player2_health_upgrades - 1)
	if player2_attack_upgrades >= 1:
		player2.damage *= 1.5
		if player2_attack_upgrades >= 2:
			player2.damage *= 1.5 ** (player2_attack_upgrades - 1)
	if player2_speed_upgrades >= 1:
		player2.speed *= 1.2
		if player2_speed_upgrades >= 2:
			player2.speed *= 1.2 ** (player2_speed_upgrades - 1)
	if player2_team_upgrades >= 1:
		yellow_tower = ARCHER_TOWER_SCENE.instantiate()
		add_child(yellow_tower)
		yellow_tower.connect("dead", _on_house_dead)
		yellow_tower.yellow()
		yellow_house.hide()
		yellow_tower.position = yellow_house.global_position
	
	if bot1_health_upgrades >= 1:
		bot1.hp *= 1.5
		if bot1_health_upgrades >= 2:
			bot1.hp *= 1.5 ** (bot1_health_upgrades - 1)
	if bot1_attack_upgrades >= 1:
		bot1.damage *= 1.5
		if bot1_attack_upgrades >= 2:
			bot1.damage *= 1.5 ** (bot1_attack_upgrades - 1)
	if bot1_speed_upgrades >= 1:
		bot1.speed *= 1.2
		if bot1_speed_upgrades >= 2:
			bot1.speed *= 1.2 ** (bot1_speed_upgrades - 1)
	if bot1_team_upgrades >= 1:
		black_tower = ARCHER_TOWER_SCENE.instantiate()
		add_child(black_tower)
		black_tower.connect("dead", _on_house_dead)
		black_tower.black()
		black_house.hide()
		black_tower.position = black_house.global_position
	
	if bot2_health_upgrades >= 1:
		bot2.hp *= 1.5
		if bot2_health_upgrades >= 2:
			bot2.hp *= 1.5 ** (bot2_health_upgrades - 1)
	if bot2_attack_upgrades >= 1:
		bot2.damage *= 1.5
		if bot2_attack_upgrades >= 2:
			bot2.damage *= 1.5 ** (bot2_attack_upgrades - 1)
	if bot2_speed_upgrades >= 1:
		bot2.speed *= 1.2
		if bot2_speed_upgrades >= 2:
			bot2.speed *= 1.2 ** (bot2_speed_upgrades - 1)
	if bot2_team_upgrades >= 1:
		red_tower = ARCHER_TOWER_SCENE.instantiate()
		add_child(red_tower)
		red_tower.connect("dead", _on_house_dead)
		red_tower.red()
		red_house.hide()
		red_tower.position = red_house.global_position

func _on_house_dead(team):
	if team == 1:
		player1.enter_dead_state()
	elif team == 2:
		player2.enter_dead_state()
	elif team == 3:
		bot1.enter_dead_state()
	else:
		bot2.enter_dead_state()

func _on_bot1_dead():
	dead_players += 1
	if dead_players >= 3:
		_round_over()

func _on_bot2_dead():
	dead_players += 1
	if dead_players >= 3:
		_round_over()

func _on_player1_dead():
	dead_players += 1
	if dead_players >= 3:
		_round_over()

func _on_player2_dead():
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
