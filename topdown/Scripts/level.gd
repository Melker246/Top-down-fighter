extends Node2D

@onready var player1: CharacterBody2D = $Player
@onready var player2: CharacterBody2D = $Player2
@onready var bot1: CharacterBody2D = $bot1

var time = 0
var last_random_input_bot1 = Vector2(0,0)
var target_priority = randf_range(0,1)

func _ready() -> void:
	await bot1.ready
	bot1.connect("bot1_dead", _on_bot1_dead())
	player1.connect("player1_dead", _on_player1_dead())
	player2.connect("player2_dead", _on_player2_dead())

func _physics_process(delta: float) -> void:
	var change_target = true
	var input_done = false
	if bot1 != null:
		if player1 != null:
			if (bot1.position.x-player1.position.x)**2 < 200**2 and (bot1.position.y-player1.position.y)**2 < 200**2:
				bot1.bot_movement_input = get_bot_movement_input_on_player_close(bot1, player1)
				if target_priority < 0.5:
					change_target = false
				input_done = true
		if player2 != null:
			if (bot1.position.x-player2.position.x)**2 < 200**2 and (bot1.position.y-player2.position.y)**2 < 200**2 and change_target:
				bot1.bot_movement_input = get_bot_movement_input_on_player_close(bot1, player2)
				input_done = true
		if not input_done:
			bot1.bot_movement_input = random_bot_input(delta)

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

func random_bot_input(delta) -> Vector2:
	time += delta
	if time > 0.5:
		var input = Vector2(0,0)
		input.x = randi_range(-1,1)
		input.y = randi_range(-1,1)
		time = 0
		last_random_input_bot1 = input
		return input
	return last_random_input_bot1

func _on_bot1_dead():
	bot1 = null

func _on_player1_dead():
	player1 = null

func _on_player2_dead():
	player2 = null
