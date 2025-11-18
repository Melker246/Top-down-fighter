extends Node2D

@onready var player1: CharacterBody2D = $Player
@onready var player2: CharacterBody2D = $Player2
@onready var bot1: CharacterBody2D = $bot1
@onready var bot2: CharacterBody2D = $bot2
@onready var blue_house: Node2D = $BlueHouse
@onready var yellow_house: Node2D = $YellowHouse
@onready var red_house: Node2D = $RedHouse
@onready var black_house: Node2D = $BlackHouse

var time = 0
var last_random_input_bot1 = Vector2(0,0)
var last_random_input_bot2 = Vector2(0,0)
var target_priority_bot1 = randf_range(0,1)
var target_priority_bot2 = randf_range(0,1)

func _ready() -> void:
	blue_house.blue()
	yellow_house.yellow()
	red_house.red()
	black_house.black()
	await bot1.ready
	bot1.connect("bot1_dead", _on_bot1_dead())
	bot2.connect("bot2_dead", _on_bot2_dead())
	player1.connect("player1_dead", _on_player1_dead())
	player2.connect("player2_dead", _on_player2_dead())

func _physics_process(delta: float) -> void:
	if bot1 != null:
		var change_target = true
		var input_done = false
		if player1 != null:
			var distance_from_bot1_to_player1 = sqrt((bot1.position.x-player1.position.x)**2+(bot1.position.y-player1.position.y)**2)
			if distance_from_bot1_to_player1 < 200:
				bot1.bot_movement_input = get_bot_movement_input_on_player_close(bot1, player1)
				if target_priority_bot1 < 1/3:
					change_target = false
				input_done = true
				if distance_from_bot1_to_player1 < 30:
					bot1.bot_attack_or_guard_input = -1
				elif distance_from_bot1_to_player1 < 90:
					bot1.bot_attack_or_guard_input = 1
				else:
					bot1.bot_attack_or_guard_input = 0
		if player2 != null:
			var distance_from_bot1_to_player2 = sqrt((bot1.position.x-player2.position.x)**2+(bot1.position.y-player2.position.y)**2)
			if distance_from_bot1_to_player2 < 200 and change_target:
				bot1.bot_movement_input = get_bot_movement_input_on_player_close(bot1, player2)
				input_done = true
				if target_priority_bot1 < 2/3:
					change_target = false
				if distance_from_bot1_to_player2 < 30:
					bot1.bot_attack_or_guard_input = -1
				elif distance_from_bot1_to_player2 < 90:
					bot1.bot_attack_or_guard_input = 1
				else:
					bot1.bot_attack_or_guard_input = 0
		if bot2 != null:
			var distance_from_bot1_to_bot2 = sqrt((bot1.position.x-bot2.position.x)**2+(bot1.position.y-bot2.position.y)**2)
			if distance_from_bot1_to_bot2 < 200 and change_target:
				bot1.bot_movement_input = get_bot_movement_input_on_player_close(bot1, bot2)
				input_done = true
				if distance_from_bot1_to_bot2 < 30:
					bot1.bot_attack_or_guard_input = -1
				elif distance_from_bot1_to_bot2 < 90:
					bot1.bot_attack_or_guard_input = 1
				else:
					bot1.bot_attack_or_guard_input = 0
		if not input_done:
			last_random_input_bot1 = random_bot_input(delta, last_random_input_bot1)
			bot1.bot_movement_input = last_random_input_bot1
			bot1.bot_attack_or_guard_input = 0
	if bot2 != null:
		var change_target = true
		var input_done = false
		if player1 != null:
			var distance_from_bot2_to_player1 = sqrt((bot2.position.x-player1.position.x)**2+(bot2.position.y-player1.position.y)**2)
			if distance_from_bot2_to_player1 < 200:
				bot2.bot_movement_input = get_bot_movement_input_on_player_close(bot2, player1)
				if target_priority_bot2 < 1/3:
					change_target = false
				input_done = true
				if distance_from_bot2_to_player1 < 30:
					bot2.bot_attack_or_guard_input = -1
				elif distance_from_bot2_to_player1 < 90:
					bot2.bot_attack_or_guard_input = 1
				else:
					bot2.bot_attack_or_guard_input = 0
		if player2 != null:
			var distance_from_bot2_to_player2 = sqrt((bot2.position.x-player2.position.x)**2+(bot2.position.y-player2.position.y)**2)
			if distance_from_bot2_to_player2 < 200 and change_target:
				bot2.bot_movement_input = get_bot_movement_input_on_player_close(bot2, player2)
				input_done = true
				if target_priority_bot2 < 2/3:
					change_target = false
				if distance_from_bot2_to_player2 < 30:
					bot2.bot_attack_or_guard_input = -1
				elif distance_from_bot2_to_player2 < 90:
					bot2.bot_attack_or_guard_input = 1
				else:
					bot2.bot_attack_or_guard_input = 0
		if bot1 != null:
			var distance_from_bot2_to_bot1 = sqrt((bot2.position.x-bot1.position.x)**2+(bot2.position.y-bot1.position.y)**2)
			if distance_from_bot2_to_bot1 < 200:
				bot2.bot_movement_input = get_bot_movement_input_on_player_close(bot2, bot1)
				input_done = true
				if distance_from_bot2_to_bot1 < 30:
					bot2.bot_attack_or_guard_input = -1
				elif distance_from_bot2_to_bot1 < 90:
					bot2.bot_attack_or_guard_input = 1
				else:
					bot2.bot_attack_or_guard_input = 0
		if not input_done:
			last_random_input_bot2 = random_bot_input(delta, last_random_input_bot2)
			bot2.bot_movement_input = last_random_input_bot2
			bot2.bot_attack_or_guard_input = 0


func get_bot_movement_input_on_player_close(bot, player) -> Vector2:
	var input = Vector2(0,0)
	if player.position.x-bot.position.x > 20:
		input.x = 1
	elif player.position.x-bot.position.x < -20:
		input.x = -1
	else:
		input.x = 0
	if player.position.y-bot.position.y > 20:
		input.y = 1
	elif player.position.y-bot.position.y < -20:
		input.y = -1
	else:
		input.y = 0
	return input

func random_bot_input(delta, last_random_input) -> Vector2:
	time += delta
	if time > 0.5:
		var input = Vector2(0,0)
		input.x = randi_range(-1,1)
		input.y = randi_range(-1,1)
		time = 0
		return input
	return last_random_input

func _on_bot1_dead():
	bot1 = null

func _on_bot2_dead():
	bot2 = null

func _on_player1_dead():
	player1 = null

func _on_player2_dead():
	player2 = null
