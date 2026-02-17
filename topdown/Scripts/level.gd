extends Node2D

const ARCHER_TOWER_SCENE = preload("res://Scenes/archer_tower.tscn")
const LANCER_SCENE = preload("res://Scenes/lancer.tscn")
const MONK_SCENE = preload("res://Scenes/monk.tscn")

@onready var player1: CharacterBody2D = $Player
@onready var player2: CharacterBody2D = $Player2
@onready var bot1: CharacterBody2D = $bot1
@onready var bot2: CharacterBody2D = $bot2
@onready var blue_house: StaticBody2D = $BlueHouse
@onready var yellow_house: StaticBody2D = $YellowHouse
@onready var red_house: StaticBody2D = $RedHouse
@onready var black_house: StaticBody2D = $BlackHouse
@onready var round_interference: CanvasLayer = $Round_interference
@onready var black_label: Label = $Hud/BlackLabel
@onready var blue_label: Label = $Hud/BlueLabel
@onready var red_label: Label = $Hud/RedLabel
@onready var yellow_label: Label = $Hud/YellowLabel
@onready var round_label: Label = $Hud/RoundLabel

var blue_tower = null
var yellow_tower = null
var black_tower = null
var red_tower = null
var blue_arrow = null
var yellow_arrow = null
var black_arrow = null
var red_arrow = null

var lancer
var monk

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

var players = []
var lancers = []
var monks = []

var round = 1

func _ready() -> void:
	players = [player1,player2,bot1,bot2]
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
	bot1.player1_pos = player1.position
	bot2.player1_pos = player1.position
	bot1.player2_pos = player2.position
	bot2.player2_pos = player2.position
	bot1.bot2_pos = bot2.position
	bot2.bot1_pos = bot1.position
	
	for lancer in lancers:
		lancer.player_position = players[lancer.team-1].global_position
		for player in lancer.target_players:
			lancer.target_players_positions = []
			lancer.target_players_positions.append(players[player-1].global_position)
	
	if blue_tower is StaticBody2D:
		if blue_tower.can_shoot:
			blue_tower.shoot_players(player2,bot1,bot2)
	
	if yellow_tower is StaticBody2D:
		if yellow_tower.can_shoot:
			yellow_tower.shoot_players(player1,bot1,bot2)
	
	if black_tower is StaticBody2D:
		if black_tower.can_shoot:
			black_tower.shoot_players(player2,player1,bot2)
	
	if red_tower is StaticBody2D:
		if red_tower.can_shoot:
			red_tower.shoot_players(player2,bot1,player1)

func _round_over():
	round += 1
	if round >= 1:
		MenuManager.game_over()
	else:
		for player in players:
			if not player.dead:
				if player.team == 1:
					Globals.blue_wins += 1
				elif player.team == 2:
					Globals.yellow_wins += 1
				elif player.team == 3:
					Globals.black_wins += 1
				elif player.team == 4:
					Globals.red_wins += 1
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
	_labels()
	_add_uppgrades()

func _reset_upgrades(player):
	player.hp = 100
	player.damage = 50
	player.speed = 1
	for lancer in lancers:
		lancers.erase(lancer)
		lancer.queue_free()
	for monk in monks:
		monks.erase(monk)
		monk.queue_free()

func _add_uppgrades():
	if player1_health_upgrades >= 1:
		player1.hp *= 1.5
		if player1_health_upgrades >= 2:
			monk = MONK_SCENE.instantiate()
			add_child(monk)
			monk.team = 1
			monk.position = blue_house.global_position
			monk.setup(1)
			monk.connect("heal", _on_heal)
			monks.append(monk)
			player1.hp *= 1.4 ** (player1_health_upgrades - 2)
	if player1_attack_upgrades >= 1:
		player1.damage *= 1.5
		if player1_attack_upgrades >= 2:
			player1.deflect = true
			player1.damage *= 1.3 ** (player1_attack_upgrades - 2)
	if player1_speed_upgrades >= 1:
		player1.speed *= 1.2
		if player1_speed_upgrades >= 2:
			player1.dash = true
			player1.speed *= 1.1 ** (player1_speed_upgrades - 2)
	if player1_team_upgrades >= 1:
		if not blue_tower is StaticBody2D:
			blue_tower = ARCHER_TOWER_SCENE.instantiate()
			add_child(blue_tower)
			blue_tower.connect("dead", _on_house_dead)
			blue_tower.blue()
			blue_house.hide()
			blue_house.collishon_shape.disabled = true
			blue_tower.position = blue_house.global_position
		else:
			blue_tower.rebuild()
			blue_house.hide()
			blue_house.collishon_shape.disabled = true
		var amount_lancers = int(player1_team_upgrades / 2)
		while amount_lancers > 0:
			lancer = LANCER_SCENE.instantiate()
			add_child(lancer)
			lancer.position = blue_house.global_position
			lancer.setup()
			lancer.connect("lancer_dead", _on_lancer_dead)
			lancers.append(lancer)
			amount_lancers -= 1
	
	if player2_health_upgrades >= 1:
		player2.hp *= 1.5
		if player2_health_upgrades >= 2:
			monk = MONK_SCENE.instantiate()
			add_child(monk)
			monk.position = yellow_house.global_position
			monk.setup(2)
			monk.connect("heal", _on_heal)
			monks.append(monk)
			player2.hp *= 1.4 ** (player2_health_upgrades - 2)
	if player2_attack_upgrades >= 1:
		player2.damage *= 1.5
		if player2_attack_upgrades >= 2:
			player2.deflect = true
			player2.damage *= 1.3 ** (player2_attack_upgrades - 2)
	if player2_speed_upgrades >= 1:
		player2.speed *= 1.2
		if player2_speed_upgrades >= 2:
			player2.dash = true
			player2.speed *= 1.1 ** (player2_speed_upgrades - 2)
	if player2_team_upgrades >= 1:
		if not yellow_tower is StaticBody2D:
			yellow_tower = ARCHER_TOWER_SCENE.instantiate()
			add_child(yellow_tower)
			yellow_tower.connect("dead", _on_house_dead)
			yellow_tower.yellow()
			yellow_house.hide()
			yellow_house.collishon_shape.disabled = true
			yellow_tower.position = yellow_house.global_position
		else:
			yellow_tower.rebuild()
			yellow_house.hide()
			yellow_house.collishon_shape.disabled = true
		var amount_lancers = int(player2_team_upgrades / 2)
		while amount_lancers > 0:
			lancer = LANCER_SCENE.instantiate()
			add_child(lancer)
			lancer.team = 2
			lancer.position = yellow_house.global_position
			lancer.setup()
			lancer.connect("lancer_dead", _on_lancer_dead)
			lancers.append(lancer)
			amount_lancers -= 1

	if bot1_health_upgrades >= 1:
		bot1.hp *= 1.5
		if bot1_health_upgrades >= 2:
			monk = MONK_SCENE.instantiate()
			add_child(monk)
			monk.position = black_house.global_position
			monk.setup(3)
			monk.connect("heal", _on_heal)
			monks.append(monk)
			bot1.hp *= 1.4 ** (bot1_health_upgrades - 2)
	if bot1_attack_upgrades >= 1:
		bot1.damage *= 1.5
		if bot1_attack_upgrades >= 2:
			bot1.deflect = true
			bot1.damage *= 1.3 ** (bot1_attack_upgrades - 2)
	if bot1_speed_upgrades >= 1:
		bot1.speed *= 1.2
		if bot1_speed_upgrades >= 2:
			bot1.dash = true
			bot1.speed *= 1.1 ** (bot1_speed_upgrades - 2)
	if bot1_team_upgrades >= 1:
		if not black_tower is StaticBody2D:
			black_tower = ARCHER_TOWER_SCENE.instantiate()
			add_child(black_tower)
			black_tower.connect("dead", _on_house_dead)
			black_tower.black()
			black_house.hide()
			black_house.collishon_shape.disabled = true
			black_tower.position = black_house.global_position
		else:
			black_tower.rebuild()
			black_house.hide()
			black_house.collishon_shape.disabled = true
		var amount_lancers = int(bot1_team_upgrades / 2)
		while amount_lancers > 0:
			lancer = LANCER_SCENE.instantiate()
			add_child(lancer)
			lancer.team = 3
			lancer.position = black_house.global_position
			lancer.setup()
			lancer.connect("lancer_dead", _on_lancer_dead)
			lancers.append(lancer)
			amount_lancers -= 1
	
	if bot2_health_upgrades >= 1:
		bot2.hp *= 1.5
		if bot2_health_upgrades >= 2:
			monk = MONK_SCENE.instantiate()
			add_child(monk)
			monk.position = red_house.global_position
			monk.setup(4)
			monk.connect("heal", _on_heal)
			monks.append(monk)
			bot2.hp *= 1.4 ** (bot2_health_upgrades - 2)
	if bot2_attack_upgrades >= 1:
		bot2.damage *= 1.5
		if bot2_attack_upgrades >= 2:
			bot2.deflect = true
			bot2.damage *= 1.3 ** (bot2_attack_upgrades - 2)
	if bot2_speed_upgrades >= 1:
		bot2.speed *= 1.2
		if bot2_speed_upgrades >= 2:
			bot2.dash = true
			bot2.speed *= 1.1 ** (bot2_speed_upgrades - 2)
	if bot2_team_upgrades >= 1:
		if not red_tower is StaticBody2D:
			red_tower = ARCHER_TOWER_SCENE.instantiate()
			add_child(red_tower)
			red_tower.connect("dead", _on_house_dead)
			red_tower.red()
			red_house.hide()
			red_house.collishon_shape.disabled = true
			red_tower.position = red_house.global_position
		else:
			red_tower.rebuild()
			red_house.hide()
			red_house.collishon_shape.disabled = true
		var amount_lancers = int(bot2_team_upgrades / 2)
		while amount_lancers > 0:
			lancer = LANCER_SCENE.instantiate()
			add_child(lancer)
			lancer.team = 4
			lancer.position = red_house.global_position
			lancer.setup()
			lancer.connect("lancer_dead", _on_lancer_dead)
			lancers.append(lancer)
			amount_lancers -= 1

func _labels():
	black_label.text = " Black Wins: " + str(Globals.black_wins)
	blue_label.text = " Blue Wins: " + str(Globals.blue_wins)
	yellow_label.text = " Yellow Wins: " + str(Globals.yellow_wins)
	red_label.text = " Red Wins: " + str(Globals.red_wins)
	round_label.text = "Round: " + str(round)
	

func _on_house_dead(team):
	if team == 1:
		if not player1.dead:
			player1.enter_dead_state()
		for monk in monks:
			if monk.team == 1:
				monks.erase(monk)
				monk.queue_free()
	elif team == 2:
		if not player2.dead:
			player2.enter_dead_state()
		for monk in monks:
			if monk.team == 2:
				monks.erase(monk)
				monk.queue_free()
	elif team == 3:
		if not bot1.dead:
			bot1.enter_dead_state()
		for monk in monks:
			if monk.team == 3:
				monks.erase(monk)
				monk.queue_free()
	else:
		if not bot2.dead:
			bot2.enter_dead_state()
		for monk in monks:
			if monk.team == 4:
				monks.erase(monk)
				monk.queue_free()

func _on_bot1_dead():
	var dead_players = 0
	for player in players:
		if player.dead:
			dead_players += 1
	for lancer in lancers:
		if lancer.team == 3:
			lancers.erase(lancer)
			lancer.hp = 0
	if dead_players >= 3:
		_round_over()

func _on_bot2_dead():
	var dead_players = 0
	for player in players:
		if player.dead:
			dead_players += 1
	for lancer in lancers:
		if lancer.team == 4:
			lancers.erase(lancer)
			lancer.hp = 0
	if dead_players >= 3:
		_round_over()

func _on_player1_dead():
	var dead_players = 0
	for player in players:
		if player.dead:
			dead_players += 1
	for lancer in lancers:
		if lancer.team == 1:
			lancers.erase(lancer)
			lancer.hp = 0
	if dead_players >= 3:
		_round_over()

func _on_player2_dead():
	var dead_players = 0
	for player in players:
		if player.dead:
			dead_players += 1
	for lancer in lancers:
		if lancer.team == 2:
			lancers.erase(lancer)
			lancer.hp = 0
	if dead_players >= 3:
		_round_over()

func _health_button_pressed():
	if player_chosing_upgrades == 1:
		player1_health_upgrades += 1
		player_chosing_upgrades += 1
		round_interference.update_text(player1_health_upgrades,player1_attack_upgrades,player1_speed_upgrades,player1_team_upgrades,player2_health_upgrades,player2_attack_upgrades,player2_speed_upgrades,player2_team_upgrades)
	elif player_chosing_upgrades == 2:
		player2_health_upgrades += 1
		round_interference.hide()
		round_interference.update_text(player1_health_upgrades,player1_attack_upgrades,player1_speed_upgrades,player1_team_upgrades,player2_health_upgrades,player2_attack_upgrades,player2_speed_upgrades,player2_team_upgrades)
		_start_new_round()

func _attack_button_pressed():
	if player_chosing_upgrades == 1:
		player1_attack_upgrades += 1
		player_chosing_upgrades += 1
		round_interference.update_text(player1_health_upgrades,player1_attack_upgrades,player1_speed_upgrades,player1_team_upgrades,player2_health_upgrades,player2_attack_upgrades,player2_speed_upgrades,player2_team_upgrades)
	elif player_chosing_upgrades == 2:
		player2_attack_upgrades += 1
		round_interference.hide()
		round_interference.update_text(player1_health_upgrades,player1_attack_upgrades,player1_speed_upgrades,player1_team_upgrades,player2_health_upgrades,player2_attack_upgrades,player2_speed_upgrades,player2_team_upgrades)
		_start_new_round()

func _speed_button_pressed():
	if player_chosing_upgrades == 1:
		player1_speed_upgrades += 1
		player_chosing_upgrades += 1
		round_interference.update_text(player1_health_upgrades,player1_attack_upgrades,player1_speed_upgrades,player1_team_upgrades,player2_health_upgrades,player2_attack_upgrades,player2_speed_upgrades,player2_team_upgrades)
	elif player_chosing_upgrades == 2:
		player2_speed_upgrades += 1
		round_interference.hide()
		round_interference.update_text(player1_health_upgrades,player1_attack_upgrades,player1_speed_upgrades,player1_team_upgrades,player2_health_upgrades,player2_attack_upgrades,player2_speed_upgrades,player2_team_upgrades)
		_start_new_round()

func _team_button_pressed():
	if player_chosing_upgrades == 1:
		player1_team_upgrades += 1
		player_chosing_upgrades += 1
		round_interference.update_text(player1_health_upgrades,player1_attack_upgrades,player1_speed_upgrades,player1_team_upgrades,player2_health_upgrades,player2_attack_upgrades,player2_speed_upgrades,player2_team_upgrades)
	elif player_chosing_upgrades == 2:
		player2_team_upgrades += 1
		round_interference.hide()
		round_interference.update_text(player1_health_upgrades,player1_attack_upgrades,player1_speed_upgrades,player1_team_upgrades,player2_health_upgrades,player2_attack_upgrades,player2_speed_upgrades,player2_team_upgrades)
		_start_new_round()

func _on_lancer_dead(lancer):
	lancers.erase(lancer)
	lancer.queue_free()

func _on_heal(team, amount, monk):
	players[team-1].hp += amount
	players[team-1].heal()
