extends Node2D

class_name House

signal dead(team)

@onready var anim: AnimationPlayer = $AnimationPlayer
@onready var sprite: Sprite2D = $Sprite2D
@onready var collishon_shape: CollisionShape2D = $CollisionShape2D

var team = 0

func destroy():
	emit_signal("dead", team)
	hide()
	collishon_shape.disabled = true

func rebuild():
	show()
	collishon_shape.disabled = false


func blue() -> void:
	anim.play("blue")
	team = 1

func yellow() -> void:
	anim.play("yellow")
	team = 2

func black() -> void:
	anim.play("black")
	team = 3

func red() -> void:
	anim.play("red")
	team = 4
