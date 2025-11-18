extends Node2D

class_name House

@onready var anim: AnimationPlayer = $AnimationPlayer
var team = 0

func blue() -> void:
	anim.play("blue")
	team = 1

func yellow() -> void:
	anim.play("yellow")
	team = 2

func red() -> void:
	anim.play("red")
	team = 3

func black() -> void:
	anim.play("black")
	team = 4
