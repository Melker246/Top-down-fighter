extends Node2D

signal heal(team,amount) #signal that is being sent out when the monk is going to heal the player

const HEAL_AMOUNT = 20

@onready var anim: AnimationPlayer = $AnimationPlayer

var team = 0 #The team of the monk, so it knows which player to heal
var anim_path = "" #the path for the animation so it can be assigned a colour

func setup(taem): #taem is the team, since team was already in use and is needed in the function
	#makes sure that the monk is getting the correct team and that the correct colour of the animation is played
	team = taem
	if team == 1:
		anim_path = "blue"
	elif team == 2:
		anim_path = "yellow"
	elif team == 3:
		anim_path = "black"
	else:
		anim_path = "red"
	anim.play(anim_path+"_idle")

func _heal(): #sends out a signal to the level script that says that it should heal the player with the same team
	emit_signal("heal", team, HEAL_AMOUNT)
	anim.play(anim_path+"_healing")
	await anim.animation_finished
	anim.play(anim_path+"_idle")

func _on_timer_timeout() -> void: #heal every 2.5 sec
	_heal()
