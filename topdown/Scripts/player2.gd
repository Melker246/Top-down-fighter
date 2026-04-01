extends CharacterBody2D

signal player2_dead #sent out when this exact player dies so the game can know when the round should be over

const MAX_SPEED = 300
const ACC = 800
const ATTACK_MOVEMENT_DEBUFF = 0.8
const GUARD_MOVEMENT_DEBUFF = 0.2

@onready var attack_timer: Timer = $AttackTimer
@onready var guard_timer: Timer = $GuardTimer
@onready var dash_timer: Timer = $DashTimer
@onready var dash_cooldown: Timer = $DashCooldown
@onready var anim: AnimationPlayer = $AnimationPlayer
@onready var anim2: AnimationPlayer = $AnimationPlayer2
@onready var sprite: Sprite2D = $Sprite2D
@onready var attack_area: Area2D = $AttackArea
@onready var heal_effect: Sprite2D = $HealEffect
@onready var collision_shape: CollisionShape2D = $CollisionShape2D

var hp = 100
var damage = 50
var speed = 1
var team = 2

var dead = false
var attack_ongoing = false
var attack_area_base_x_pos = 0
var body_inside_attack = 0
var attacked_body = []
var can_attack = true
var guard_ongoing = false
var dash = false
var dash_ongoing = false
var can_dash = true
var deflect = false

var layer1 = true
var layer2 = false
var layer3 = false
#keeps track of the layer the player is on

enum {IDLE, RUN, ATTACK, GUARD, DASH, DEAD}
var state = IDLE

func _ready() -> void:
	anim.play("idle")
	attack_area_base_x_pos = attack_area.position.x #get the attack area position so it can later change depending on what direction the player is moving

################# STATE MACHINE #################
func _physics_process(delta: float) -> void:
	if not dead:
		match state: #Enter the function for the state that the player is in
			IDLE:
				_idle_state(delta)
			RUN:
				_run_state(delta)
			ATTACK:
				_attack_state(delta)
			GUARD:
				_guard_state(delta)
			DASH:
				_dash_state(delta)
			DEAD:
				_dead_state(delta)

################ HELP FUNCTIONS #######
func _movement(delta, input, speedkoefficent) -> void: #Move the player and flip the attack area and the sprite depending on the direction of the movement
	input = input.normalized()
	velocity.x = move_toward(velocity.x, input.x*MAX_SPEED*speedkoefficent, ACC*delta)
	velocity.y = move_toward(velocity.y, input.y*MAX_SPEED*speedkoefficent, ACC*delta)
	move_and_slide()
	if velocity.x < 0:
		sprite.flip_h = true
		attack_area.position.x = attack_area_base_x_pos*-1
	elif velocity.x > 0:
		sprite.flip_h = false
		attack_area.position.x = attack_area_base_x_pos

func _hp_control() -> bool: #Dead = true, alive = false, check if the player is still alive (hp more than 0)
	if hp <= 0:
		return true
	else:
		return false

################ STATE FUNCTIONS ################
func _idle_state(delta) -> void: #If the player isn't moving
	var input = Vector2(0, 0)
	input.y = Input.get_axis("up2", "down2") 
	input.x = Input.get_axis("left2", "right2")
	_movement(delta, input, speed) #move the player
	if _hp_control(): #Chack if the player is still alive
		enter_dead_state()
	if velocity != Vector2(0, 0): #check if the player should enter another state
		_enter_run_state()
	if Input.is_action_just_pressed("attack2"):
		_enter_attack_state()
	elif Input.is_action_just_pressed("guard2"):
		_enter_guard_state()
	elif Input.is_action_just_pressed("dash2") and dash and can_dash:
		_enter_dash_state()


func _run_state(delta) -> void: #if the is moving but not doing something else
	var input = Vector2(0, 0)
	input.y = Input.get_axis("up2", "down2")
	input.x = Input.get_axis("left2", "right2")
	_movement(delta, input, speed) #move the player
	if _hp_control(): #check if the player is still alive
		enter_dead_state()
	if velocity == Vector2(0, 0): #check if the player should enter another state
		enter_idle_state()
	if Input.is_action_just_pressed("attack2"):
		_enter_attack_state()
	elif Input.is_action_just_pressed("guard2"):
		_enter_guard_state()
	elif Input.is_action_just_pressed("dash2") and dash and can_dash:
		_enter_dash_state()


func _attack_state(delta) -> void:
	var input = Vector2(0, 0)
	input.y = Input.get_axis("up2", "down2")
	input.x = Input.get_axis("left2", "right2")
	_movement(delta, input, ATTACK_MOVEMENT_DEBUFF*speed) #move and add a debuff to the movement speed for attacking
	if body_inside_attack >= 1 and can_attack and attack_ongoing:
		#If there is a target in the attacked area and attack is of cooldown and the attack was activated before the colldown reset 
		can_attack = false #Make sure the player can't attack before the colldown
		for body in attacked_body: #Loop through all the targets inside the attack area
			if body is House or body is Tower: #If the target is a house or tower destroy it
				if team != body.team: #Make sure the target isn't on your team
					body.destroy() #Call a function in the house/tower script that tells it to disable itself
			elif (body.layer1 and layer1) or (body.layer2 and layer2) or (body.layer3 and layer3):
				#If the target is antother body, check wich layer it is on and make sure the player is on the same one
				if not body.guard_ongoing: #If the target is guarding nothing should be done, otherwise deal damage to it
					body.hp -= damage
				elif body.deflect: #If it is guarding and it has deflect upgrade deal damage to yourself equal to 25% of your own damage
					hp -= 0.25*damage
	if _hp_control(): #Check if hp is over 0
		enter_dead_state()
	if not attack_ongoing: 
		if velocity == Vector2(0,0):
			enter_idle_state()
		else:
			_enter_run_state()
		#If the attack is over enter idle or run state based on velocity
	if Input.is_action_just_pressed("guard2"):
		_enter_guard_state()
	elif Input.is_action_just_pressed("dash2") and dash and can_dash:
		_enter_dash_state()



func _guard_state(delta) -> void:
	var input = Vector2(0, 0)
	input.y = Input.get_axis("up2", "down2")
	input.x = Input.get_axis("left2", "right2")
	_movement(delta, input, GUARD_MOVEMENT_DEBUFF*speed) #move the player and apply movement debuff so the player isn't as fast
	if _hp_control(): #Check if the player should be alive
		enter_dead_state()
	if not guard_ongoing: #If the guarding is ove endter either idle or run state
		if velocity == Vector2(0,0):
			enter_idle_state()
		else:
			_enter_run_state()

func _dash_state(delta) -> void:
	move_and_slide() #move the player 
	if _hp_control(): #Check if the player is alive
		enter_dead_state()
	if not dash_ongoing: #When the dash is over reset the velocity and change state
		velocity /= 4
		if velocity == Vector2(0,0):
			enter_idle_state()
		else:
			_enter_run_state()

func _dead_state(delta) -> void:
	pass


################ ENTER STATE FUNCTIONS ###############
func enter_idle_state() -> void: #when the player just went idle
	state = IDLE
	anim.play("idle")

func _enter_run_state() -> void: #when the player just started running or ended an attack etc
	state = RUN
	anim.play("run")

func _enter_attack_state() -> void: #when the player just pressed attack
	state = ATTACK
	attack_ongoing = true
	attack_timer.start()
	anim.play("attack")
	$AudioStreamPlayer2.play()

func _enter_guard_state() -> void: #when the player just pressed guard
	state = GUARD
	guard_ongoing = true
	guard_timer.start()
	if deflect:
		anim.play("deflect")
	else:
		anim.play("guard")

func _enter_dash_state() -> void: #when the player just pressed dash
	state = DASH
	velocity *= 4
	if velocity.x > 0:
		sprite.rotation = PI/9
	elif velocity.x < 0:
		sprite.rotation = -PI/9
	$AudioStreamPlayer3.play()
	dash_ongoing = true
	can_dash = false
	dash_cooldown.start()
	dash_timer.start()

func enter_dead_state() -> void: #when the player just died
	state = DEAD
	anim.play("death")
	$AudioStreamPlayer.play()
	await anim.animation_finished
	dead = true
	emit_signal("player2_dead") #tell the level the player is dead
	collision_shape.disabled = true
	global_position = Vector2(-1000,-2000)
	velocity = Vector2(0,0)
	#Disable the function of the player


func _on_attack_area_body_entered(body: Node2D) -> void:
	body_inside_attack += 1
	attacked_body.append(body) #list of all the bodys inside the attack area

func _on_attack_area_body_exited(body: Node2D) -> void:
	body_inside_attack -= 1
	attacked_body.erase(body)

func _on_attack_timer_timeout() -> void:
	attack_ongoing = false
	can_attack = true

func _on_guard_timer_timeout() -> void:
	guard_ongoing = false

func _on_dash_timer_timeout() -> void:
	sprite.rotation = 0
	dash_ongoing = false

func _on_dash_cooldown_timeout() -> void:
	can_dash = true

func heal(): #show the animation of the heal not the actual healing
	heal_effect.show()
	anim2.play("heal")
	await anim2.animation_finished
	heal_effect.hide()
