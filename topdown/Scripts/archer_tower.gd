extends StaticBody2D

class_name Tower

#preload to the arrow so it can be spawned in the script easily
const ARROW_SCENE = preload("res://Scenes/arrow.tscn")

#Signal to be emitted once the tower is dead, the team variabel will also go along with signal to the level script
signal dead

@onready var anim: AnimationPlayer = $AnimationPlayer
@onready var tower: Sprite2D = $Tower
@onready var archer: Sprite2D = $Archer
@onready var collishon_shape: CollisionShape2D = $CollisionShape2D
@onready var shoot_timer: Timer = $ShootTimer
@onready var shoot_anim_offset: Timer = $ShootAnimationOffset

#The team of the archer tower, used to make sure it doesn't deal damage to its own player
var team = 0


#variables to keep track of the state of the tower
var can_shoot = true
var destroyed = false

func shoot_players(player1,player2,player3):  #Called if the tower can shoot, called from physics process in level
	if not destroyed:    #Check to see if the tower is still alive
		if (player1.position-position).length() < 300 or (player2.position-position).length() < 300 or (player3.position-position).length() < 300:
			#Tower will only shoot if a player is in a 300 px radius
			var closest_target = null
			shoot_timer.start()
			shoot_anim_offset.start()
			can_shoot = false
			if team == 1:
				anim.play("blue_shoot")
			elif team == 2:
				anim.play("yellow_shoot")
			elif team == 3:
				anim.play("black_shoot")
			else:
				anim.play("red_shoot")
			#Start timers and animations and make sure the tower only shoots once
			if (player1.position-position).length() < (player2.position-position).length() and (player1.position-position).length() < (player3.position-position).length():
				closest_target = player1
			elif (player2.position-position).length() < (player3.position-position).length():
				closest_target = player2
			else:
				closest_target = player3
			#Get the closest player and set it as the target for the arrow
			await shoot_anim_offset.timeout
			#Wait for the animation to play far enough that the archer has shoot his bow
			var arrow = ARROW_SCENE.instantiate()
			add_child(arrow)
			arrow.team = team
			arrow.position = Vector2(5,-124)
			arrow.target_pos = closest_target.position
			#Spawn in the arrow scene and give it its target, postiton and team to make sure it can't hurt its own player
			await anim.animation_finished
			if team == 1:
				anim.play("blue_idle")
			elif team == 2:
				anim.play("yellow_idle")
			elif team == 3:
				anim.play("black_idle")
			else:
				anim.play("red_idle")
			#Once the ashooting animation is over the node will start its idle animation again

func destroy():  #Called when a player or bot attacks it and it disables the functions of the tower
	emit_signal("dead", team)  #Sent to level to kill the player of the same team
	hide()
	destroyed = true
	collishon_shape.disabled = true

func rebuild():  #Called at the begining of a round to make sure that the tower is still intact and enablas all the functions of the tower
	show()
	destroyed = false
	collishon_shape.disabled = false

func blue() -> void:
	anim.play("blue_idle")
	team = 1

func yellow() -> void:
	anim.play("yellow_idle")
	team = 2

func black() -> void:
	anim.play("black_idle")
	team = 3

func red() -> void:
	anim.play("red_idle")
	team = 4

#All four functions above make sure the tower is the correct colour once it has been spawned in

func _on_shoot_timer_timeout() -> void: #Timer to keep track of if the tower can shoot, has a 2 second cool down beetween arrows
	can_shoot = true
