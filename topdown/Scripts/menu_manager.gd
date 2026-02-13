extends Node2D

const LEVEL_SCENE = "res://Scenes/level.tscn"

func start():
	$AnimationPlayer.play("fade_in")
	await $AnimationPlayer.animation_finished
	$AnimationPlayer.play("fade_out")
	get_tree().change_scene_to_file(LEVEL_SCENE)
