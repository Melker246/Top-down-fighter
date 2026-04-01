extends CharacterBody2D

#Signal for when this exact bot dies
signal bot2_dead

#constants for the speed of the bot
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
@onready var navigation_agent: NavigationAgent2D = $NavigationAgent2D
@onready var collision_shape: CollisionShape2D = $CollisionShape2D

#The inputs used in the part of the script that is similair to the player scripts
var bot_movement_input = Vector2(0,0)
var bot_attack_or_guard_input = null  #-1 = guard, 0 = dash, 1 = attack

#to find out which player is closest and to then target that player with your movement (move closer to the player)
var player1_pos = Vector2(0,0)
var player2_pos = Vector2(0,0)
var bot1_pos = Vector2(0,0)
var distance_to_player1 = 0
var distance_to_player2 = 0
var distance_to_bot1 = 0

#the base stats of the player
var hp = 100
var damage = 50
var speed = 1

#The team of the player, used to group up all the nodes that are on the bots team
var team = 3

#Used to find out what the bot is doing and what it can see
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

#The layer of the map that the bot is on
var layer1 = true
var layer2 = false
var layer3 = false

#Which type of state the bot is currently in
enum {IDLE, RUN, ATTACK, GUARD, DASH, DEAD}
var state = IDLE

func _ready() -> void: 
	anim.play("idle")
	#Start the game of with an idle animation since the bot will have a velocity if 0 in the absolut begining
	attack_area_base_x_pos = attack_area.position.x
	#Find a position for the attack area so it can be mirrored when the bot is running left

################# STATE MACHINE #################
func _physics_process(delta: float) -> void:
	if not dead:  #Make sure the bot is alive outherwise it should do nothing
		get_input() #Set the target postion for the navigation agent and the input regarding attack, dash and guard
		bot_movement_input = navigation_agent.get_next_path_position() - global_position
		#make the movement input the next position for the navigation agent
		match state:
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
		#get the state the bot is currently in

################ HELP FUNCTIONS ############
#Move the player, and flip the sprite and attack area if runing left
func _movement(delta, input: Vector2, speedkoefficent) -> void:
	input = input.normalized()  #Make sure the hypothenuse is 1 (or 0)
	velocity.x = move_toward(velocity.x, input.x*MAX_SPEED*speedkoefficent, ACC*delta)
	velocity.y = move_toward(velocity.y, input.y*MAX_SPEED*speedkoefficent, ACC*delta)
	move_and_slide()
	if velocity.x < 0:
		sprite.flip_h = true
		attack_area.position.x = attack_area_base_x_pos*-1
	elif velocity.x > 0:
		sprite.flip_h = false
		attack_area.position.x = attack_area_base_x_pos
	#Flip the sprite and attack area

func _hp_control() -> bool: #Dead = true, alive = false
	#Check if the bot still has hp
	if hp <= 0:
		return true
	else:
		return false

func get_input(): #Get the navigation agent position and find out if the bot should attack
	if player1_pos.length() > 2000 and player2_pos.length() > 2000 and bot1_pos.length() > 2000:
		bot_movement_input = Vector2(0,0)
		bot_attack_or_guard_input = null
		#If all the other players are dead no input shold be done
	else:
		#Get the distances to the diffrent players
		if player1_pos is Vector2:
			distance_to_player1 = sqrt((player1_pos.x-position.x)**2+(player1_pos.y-position.y)**2)
		if player2_pos is Vector2:
			distance_to_player2 = sqrt((player2_pos.x-position.x)**2+(player2_pos.y-position.y)**2)
		if bot1_pos is Vector2:
			distance_to_bot1 = sqrt((bot1_pos.x-position.x)**2+(bot1_pos.y-position.y)**2)
		#Check if player1 is closest
		if distance_to_player1 < distance_to_player2 and distance_to_player1 < distance_to_bot1:
			navigation_agent.target_position = player1_pos
			#If player1 is closest, they will be the target
			if distance_to_player1 < 70:
				bot_attack_or_guard_input = 1
			#if player1 is closest and within 70 px, start attack
			elif distance_to_player1 < 100:
				bot_attack_or_guard_input = -1
			#if player1 is closest and within 100 to 70px, start guard
			else:
				bot_attack_or_guard_input = 0
			#if player1 is closest but over 100 px away, dash towards player
		#Check if player2 is closest
		elif distance_to_player2 < distance_to_bot1:
			navigation_agent.target_position = player2_pos
			#If player2 is closest, they will be the target
			if distance_to_player2 < 70:
				bot_attack_or_guard_input = 1
			#if player2 is closest and within 70 px, start attack
			elif distance_to_player2 < 100:
				bot_attack_or_guard_input = -1
			#if player2 is closest and within 100 to 70 px, start attack
			else:
				bot_attack_or_guard_input = 0
			#if player1 is closest but over 100 px away, dash towards the player
		else: #if player1 and player2 isn't closest, bot1 has to be
			navigation_agent.target_position = bot1_pos
			#Set bot1 as the target
			if distance_to_bot1 < 70:
				bot_attack_or_guard_input = 1
			#if bot1 is closest and within 70 px, start attack
			elif distance_to_bot1 < 100:
				bot_attack_or_guard_input = -1
			#if bot1 is closest and within 100 to 70 px, start guard
			else:
				bot_attack_or_guard_input = 0
			#if bot1 is closest but over 100 px, dash towards the player

################ STATE FUNCTIONS ################
func _idle_state(delta) -> void:  #If the bot is in idle state aka not moving
	var input = bot_movement_input
	_movement(delta, input, speed) #move the bot
	if _hp_control(): #Check if the bot still has hp
		enter_dead_state()
	#Check if it should enter other states
	if velocity != Vector2(0, 0): #If the bot is moving enter run state
		_enter_run_state()
	if bot_attack_or_guard_input == 1: #If the bot has input to attakc, attack
		_enter_attack_state()
	elif bot_attack_or_guard_input == -1: #If the bot has input to guard, guard
		_enter_guard_state()
	elif bot_attack_or_guard_input == 0 and dash and can_dash: #If input is to dash and dash is unlocked and of cooldown, dash
		_enter_dash_state()

func _run_state(delta) -> void: #If the bot is in run state aka moving, but not doing anything special like attacking
	var input = bot_movement_input
	_movement(delta, input, speed) #Move
	if _hp_control(): #Check the hp
		enter_dead_state()
	#Enter other states
	if velocity == Vector2(0, 0):
		enter_idle_state()
	if bot_attack_or_guard_input == 1:
		_enter_attack_state()
	elif bot_attack_or_guard_input == -1:
		_enter_guard_state()
	elif bot_attack_or_guard_input == 0 and dash and can_dash:
		_enter_dash_state()

func _attack_state(delta) -> void: #If the bot is attacking
	var input = bot_movement_input
	_movement(delta, input, ATTACK_MOVEMENT_DEBUFF*speed) #move and add a debuff to the movement speed for attacking
	if body_inside_attack >= 1 and can_attack and attack_ongoing:
		#If there is a target in the attacked area and attack is of cooldown and the attack was activated before the colldown reset 
		can_attack = false #Make sure the bot can't attack before the colldown
		for body in attacked_body: #Loop through all the targets inside the attack area
			if body is House or body is Tower: #If the target is a house or tower destroy it
				if team != body.team: #Make sure the target isn't on your team
					body.destroy() #Call a function in the house/tower script that tells it to disable itself
			elif (body.layer1 and layer1) or (body.layer2 and layer2) or (body.layer3 and layer3):
				#If the target is antother body, check wich layer it is on and make sure the bot is on the same one
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
	if bot_attack_or_guard_input == -1: #Override the attack with guard if the input says so
		_enter_guard_state()
	elif bot_attack_or_guard_input == 0 and dash and can_dash: #Override the attakc with dash if the input says so
		_enter_dash_state()


func _guard_state(delta) -> void: #If the bot is guarding
	var input = bot_movement_input
	_movement(delta, input, GUARD_MOVEMENT_DEBUFF*speed) #move the bot and apply movement debuff so the bot isn't as fast
	if _hp_control(): #Check if the bot should be alive
		enter_dead_state()
	if not guard_ongoing: #If the guarding is ove endter either idle or run state
		if velocity == Vector2(0,0):
			enter_idle_state()
		else:
			_enter_run_state()

func _dash_state(delta) -> void: #If the bot is dashing
	move_and_slide() #Move no direction change can be done and no velocity change
	if _hp_control(): #Check if bot is alive
		enter_dead_state()
	if not dash_ongoing: #If dash is over reset the velocity
		velocity /= 4
		if velocity == Vector2(0,0):
			enter_idle_state()
		else:
			_enter_run_state()

func _dead_state(delta) -> void: #If the player is dead
	pass #Don't do anything since its dead


################ ENTER STATE FUNCTIONS ###############
func enter_idle_state() -> void: #If no input and no velocity just been made
	state = IDLE #Change the state and therfore also the function it enters in physics process
	anim.play("idle") #Change the animation

func _enter_run_state() -> void: #If no guard/attack/dash input and velocity over 0
	state = RUN
	anim.play("run")

func _enter_attack_state() -> void:
	state = ATTACK
	attack_ongoing = true #If an attack is ongoing no new attack will happen
	attack_timer.start() #Start timer to then end the attack
	anim.play("attack")
	$AudioStreamPlayer2.play() #Play the sword sound effect

func _enter_guard_state() -> void: #If guard input just made
	state = GUARD
	guard_ongoing = true #If guarding should not be able to take damage
	guard_timer.start()
	if deflect:  #If it is guarding do that anim otherwise if deflect do that anim
		anim.play("deflect")
	else:
		anim.play("guard")

func _enter_dash_state() -> void: #If dash input just made
	state = DASH
	velocity *= 4  #Go faster (as that is what a dash is)
	if velocity.x > 0: #Rotate the character tog give the user visual input of the action
		sprite.rotation = PI/9 #Rotate it diffrent directions depending on the direction of the characters movement
	elif velocity.x < 0:
		sprite.rotation = -PI/9
	$AudioStreamPlayer3.play() #Play a dash sound effect sounds like a swoosh
	dash_ongoing = true #make sure the dash will continue throughout the dash but not for longer
	can_dash = false #make sure the bot can't dash twice without waiting for the colldown
	dash_cooldown.start() #Start a timer for the next time the bot can start a dash
	dash_timer.start() #Start a timer for the duration of the dash to make sure the bot't do go to far

func enter_dead_state() -> void: #If hp is below 0
	state = DEAD
	anim.play("death")
	$AudioStreamPlayer.play() #Play the death sound effect
	await anim.animation_finished #Wait for the death animation to finish
	dead = true #Used to stop the script from going when the bot is dead without having to remove it as node
	emit_signal("bot2_dead") #Send out a singal to the level script so that the level knows it is dead
	collision_shape.disabled = true #Disable the hitbox so that the bot stops interfering with the map/players
	global_position = Vector2(-2000,-2000) #set the position to really far away so it doesn't become a target of the other bot
	velocity = Vector2(0,0) #Make sure the bot can't move around when dead as it could then maybe come back to the map but outside


############# Other shit ###########
func _on_attack_area_body_entered(body: Node2D) -> void: #If a body enters the attack area
	body_inside_attack += 1 #The amount of targets the bot can attaak, used to loop through attack the attack enought times that all the targets gets damaged
	attacked_body.append(body) #Add the body to a list of all the bodys that are within the area to then loop through it and aplly the damage

func _on_attack_area_body_exited(body: Node2D) -> void: #If a body leaves the attack area
	body_inside_attack -= 1 #Corrects the amount of targets
	attacked_body.erase(body) #Removes the body from the list of bodys that would take damage

func _on_attack_timer_timeout() -> void: #When the attack is over make sure the attack ends and that you can attack again
	attack_ongoing = false
	can_attack = true

func _on_guard_timer_timeout() -> void: #when the guard is over
	guard_ongoing = false

func _on_dash_timer_timeout() -> void: #when the dash is over
	sprite.rotation = 0
	dash_ongoing = false

func _on_dash_cooldown_timeout() -> void: #when the dash is avaible again, aka of cooldown
	can_dash = true


func heal(): #when the bot is getting healed from the monk this is called via the level script
	heal_effect.show() #show the sprite for healing
	anim2.play("heal") #play the animation
	await anim2.animation_finished
	heal_effect.hide() #when the animation is over hide the heal sprite
