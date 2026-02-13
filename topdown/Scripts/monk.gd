extends Node2D

signal heal(team,amount,monk)

const HEAL_AMOUNT = 20

@onready var anim: AnimationPlayer = $AnimationPlayer

var team = 0
var anim_path = ""

func setup(taem):     #taem is the team
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

func _heal():
	emit_signal("heal", team, HEAL_AMOUNT, self)
	anim.play(anim_path+"_healing")
	await anim.animation_finished
	anim.play(anim_path+"_idle")

func _on_timer_timeout() -> void:
	_heal()
