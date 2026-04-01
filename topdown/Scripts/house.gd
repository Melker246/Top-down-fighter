extends Node2D

class_name House

signal dead(team) #Sent out when house dies, sends the team so it doesn't kill its own player

@onready var anim: AnimationPlayer = $AnimationPlayer
@onready var sprite: Sprite2D = $Sprite2D
@onready var collishon_shape: CollisionShape2D = $CollisionShape2D

var team = 0
#The team the house is asinged to

func destroy(): #Called when a player/bot attacks it
	emit_signal("dead", team) #Send out a signal to the level script to kill its own player
	hide()
	collishon_shape.disabled = true #Disable the function of the house

func rebuild(): #Enable the function of the house again
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
#Assign the team and play animations for each colour
