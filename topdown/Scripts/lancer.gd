extends CharacterBody2D

class_name Lancer

signal lancer_dead(lancer) #when the lancer dies this is emitted

const MAX_SPEED = 300
const ACC = 800

const attack_area_postition_top = Vector2(5,-69)
const attack_area_postition_top_side = Vector2(68,-41)
const attack_area_postition_side = Vector2(102,12)
const attack_area_postition_down_side = Vector2(50,82)
const attack_area_postition_down = Vector2(-6,95)
#Positions for where the attack postition should be depending on the direction the lancer is attacking

@onready var sprite: Sprite2D = $Sprite2D
@onready var attack_area: Area2D = $AttackArea
@onready var player_detecter: Area2D = $PlayerDetecter
@onready var anim: AnimationPlayer = $AnimationPlayer

var team = 0
#The team of the lancer

var hp = 25
var damage = 10

var target_players_positions = [] #What is the position of the players inside the playerdetecter area, updates every physics process from the level script
var target_players = [] #The players inside the detecter area
var targets_inside_area = 0 #The amount of targets inside the area
var player_position = Vector2(0,0) #The position of the player on the same team
var guard_ongoing = false #Used to not crash the game if a player attacks it
var attack = true #If the bot can attack
var attacked_body = null #The body (player) inside the attack area, the body that will recive damage
var dead = false

var layer1 = true
var layer2 = false
var layer3 = false
#The layer the lancer is on

enum{TOP,TOP_RIGHT,RIGHT,DOWN_RIGHT,DOWN,DOWN_LEFT,LEFT,TOP_LEFT} #The possible directions of the attack
var att_dir = TOP #THe current  direction of the attack
var path = "" #Which colour of the animation should be

func setup(): #Give the lancer the appropraiate collsion laers and the animation path, called when spawned
	set_collision_layer_value(team+1,true)
	attack_area.set_collision_mask_value(team+1,false)
	player_detecter.set_collision_mask_value(team+1,false)
	if team == 1:
		path = "blue"
	elif team == 2:
		path = "yellow"
	elif team == 3:
		path = "black"
	elif team == 4:
		path = "red"

func _physics_process(delta: float) -> void:
	if not dead:
		if targets_inside_area > 0: #If a target is close, target it wiht movement and attack if closer than 200 px, and play the correct animation
			var closest_target_pos = target_players_positions[0] - global_position
			for pos in target_players_positions:
				if (pos - global_position).length() < closest_target_pos.length():
					closest_target_pos = pos - global_position
			if closest_target_pos.length() > 100:
				_movement(closest_target_pos, delta)
			else:
				_movement(Vector2(0,0), delta)
			if closest_target_pos.length() < 200:
				_attack(closest_target_pos)
			elif velocity == Vector2(0,0):
				_anim(false, false) 
			else:
				_anim(false, true)
		else: #If no target is close, follow the player on the same team and play the correct anim
			var target_pos = player_position - global_position
			if target_pos.length() > 150:
				_movement(target_pos, delta)
			else:
				_movement(Vector2(0,0), delta)
			if velocity == Vector2(0,0):
				_anim(false, false) 
			else:
				_anim(false, true)
		if _hp_control(): #Check if the bot is alive
			_dead()
			dead = true

func _movement(target, delta): #Move the player
	target = target.normalized()
	velocity.x = move_toward(velocity.x, target.x*MAX_SPEED, ACC*delta)
	velocity.y = move_toward(velocity.y, target.y*MAX_SPEED, ACC*delta)
	move_and_slide()
	if velocity.x < 0:
		sprite.flip_h = true
	elif velocity.x > 0:
		sprite.flip_h = false


func _hp_control() -> bool: #Dead = true, alive = false, used to check if the lancer should still be alive
	if hp <= 0:
		return true
	else:
		return false

func _attack(target: Vector2):
	if target.x > 10:
		if target.y < -10:
			attack_area.position = attack_area_postition_top_side
			att_dir = TOP_RIGHT
		elif target.y > 10:
			attack_area.position = attack_area_postition_down_side
			att_dir = DOWN_RIGHT
		else:
			attack_area.position = attack_area_postition_side
			att_dir = RIGHT
	elif target.x < -10:
		if target.y < -10:
			attack_area.position = Vector2(-1*attack_area_postition_top_side.x, attack_area_postition_top_side.y)
			att_dir = TOP_LEFT
		elif target.y > 10:
			attack_area.position = Vector2(-1*attack_area_postition_down_side.x, attack_area_postition_down_side.y)
			att_dir = DOWN_LEFT
		else:
			attack_area.position = Vector2(-1*attack_area_postition_side.x, attack_area_postition_side.y)
			att_dir = LEFT
	else:
		if target.y < -10:
			attack_area.position = attack_area_postition_top
			att_dir = TOP
		elif target.y > 10:
			attack_area.position = attack_area_postition_down
			att_dir = DOWN
	"""Get the dircetion of the attack"""
	if attack: #Deal damage if the target is on the same layer and start a cooldown timer
		if attacked_body is CharacterBody2D:
			if not attacked_body.guard_ongoing and ((attacked_body.layer1 and layer1) or (attacked_body.layer2 and layer2) or (attacked_body.layer3 and layer3)):
				attacked_body.hp -= damage
				attack = false
				$Timer.start()
	_anim(true, false) #play animations

func _anim(attacks, run): #attacks = true if the lancer is attacking, run = true if the bot is running but not attacking
	if attacks:
		match att_dir:
			TOP:
				anim.play(path+"_top_att")
			TOP_RIGHT:
				anim.play(path+"_top_side_att")
			RIGHT:
				anim.play(path+"_side_att")
			DOWN_RIGHT:
				anim.play(path+"_down_side_att")
			DOWN:
				anim.play(path+"_down_att")
			DOWN_LEFT:
				anim.play(path+"_down_side_att")
				sprite.flip_h = true
			LEFT:
				anim.play(path+"_side_att")
				sprite.flip_h = true
			TOP_LEFT:
				anim.play(path+"_top_side_att")
				sprite.flip_h = true
		#Play the animation based on the direction of the attack and for the correct colour
	elif run:
		anim.play(path+"_run")
	else: #If not running or attacking play the idle animation
		anim.play(path+"_idle")

func _dead(): #When the lancer dies
	anim.play("death")
	await anim.animation_finished
	emit_signal("lancer_dead", self) #Send out a singal containing itself to remove it from all references in level


func _on_player_detecter_body_entered(body: Node2D) -> void:
	if body.team != team:
		targets_inside_area += 1
		target_players.append(body.team)

func _on_player_detecter_body_exited(body: Node2D) -> void:
	if body.team != team:
		targets_inside_area -= 1
		target_players.erase(body.team)


func _on_attack_area_body_entered(body: Node2D) -> void:
	attacked_body = body

func _on_attack_area_body_exited(body: Node2D) -> void:
	attacked_body = null

func _on_timer_timeout() -> void:
	attack = true
