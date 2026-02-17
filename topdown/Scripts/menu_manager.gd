extends Node2D

const LEVEL_SCENE = "res://Scenes/level.tscn"
const GAME_OVER_SCENE = "res://Scenes/game_over_menu.tscn"

@onready var anim: AnimationPlayer = $AnimationPlayer

var is_paused = false

func start():
	anim.play("fade_in")
	await anim.animation_finished
	anim.play("fade_out")
	get_tree().change_scene_to_file(LEVEL_SCENE)

func game_over():
	anim.play("fade_in")
	await anim.animation_finished
	anim.play("fade_out")
	get_tree().change_scene_to_file(GAME_OVER_SCENE)

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("pause"):
		toggle_pause()

func quit():
	get_tree().quit()

func toggle_pause():
	is_paused = not is_paused
	get_tree().paused = is_paused
	$PauseMenu.visible = is_paused
