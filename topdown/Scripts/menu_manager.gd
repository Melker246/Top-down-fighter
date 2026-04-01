extends Node2D

const LEVEL_SCENE = "res://Scenes/level.tscn"
const START_SCENE = "res://Scenes/start_menu.tscn"
const GAME_OVER_SCENE = "res://Scenes/game_over_menu.tscn"

@onready var anim: AnimationPlayer = $AnimationPlayer

var is_paused = false #If the game is paused or not

func start(): #Change the scene to the start scene, called from pause menu and game over menu
	anim.play("fade_in")
	await anim.animation_finished
	anim.play("fade_out")
	get_tree().change_scene_to_file(START_SCENE)

func start_level(): #start the level, called from start menu
	anim.play("fade_in")
	await anim.animation_finished
	anim.play("fade_out")
	get_tree().change_scene_to_file(LEVEL_SCENE)
	$PauseMenu.audio.stream_paused = true

func game_over(): #change to the gamer over scene, called when game has ended
	anim.play("fade_in")
	await anim.animation_finished
	anim.play("fade_out")
	get_tree().change_scene_to_file(GAME_OVER_SCENE)

func _unhandled_input(event: InputEvent) -> void: #when an input that has not been used anywhere else in the script, this is called
	if event.is_action_pressed("pause"): #If the unhadled input is pause (esc) the game will toggle pause, so if it was paused it will resume and otherwise it will pause
		toggle_pause()

func quit(): #When the user wants to stop this function is called either from game over menu or pause menu
	get_tree().quit()

func toggle_pause(): #flips if the game is paused or not, makes the pause menu visible and usable if it pauses and does the opposite if the resumes
	is_paused = not is_paused
	get_tree().paused = is_paused
	$PauseMenu.visible = is_paused
	$PauseMenu.audio.stream_paused = not is_paused
