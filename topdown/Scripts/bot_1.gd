extends CharacterBody2D

signal bot1_dead

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

var bot_movement_input = Vector2(0,0)
var bot_attack_or_guard_input = 0

var player1_pos = Vector2(0,0)
var player2_pos = Vector2(0,0)
var bot2_pos = Vector2(0,0)
var distance_to_player1 = 0
var distance_to_player2 = 0
var distance_to_bot2 = 0

var hp = 100
var damage = 50
var speed = 1
var team = 3

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

enum {IDLE, RUN, ATTACK, GUARD, DASH, DEAD}
var state = IDLE

func _ready() -> void:
	anim.play("idle")
	attack_area_base_x_pos = attack_area.position.x

################# STATE MACHINE #################
func _physics_process(delta: float) -> void:
	if not dead:
		get_input()
		bot_movement_input = navigation_agent.get_next_path_position() - global_position
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

################ HELP FUNCTIONS ############
func _movement(delta, input: Vector2, speedkoefficent) -> void:
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

func _hp_control() -> bool: #Dead = true, alive = false
	if hp <= 0:
		return true
	else:
		return false

func get_input():
	if player1_pos == Vector2(-1000,-1000) and player2_pos == Vector2(-1000,-2000) and bot2_pos == Vector2(-2000,-1000):
		bot_movement_input = Vector2(0,0)
		bot_attack_or_guard_input = 0
	else:
		if player1_pos is Vector2:
			distance_to_player1 = sqrt((player1_pos.x-position.x)**2+(player1_pos.y-position.y)**2)
		else:
			distance_to_player1 = 4095
		if player2_pos is Vector2:
			distance_to_player2 = sqrt((player2_pos.x-position.x)**2+(player2_pos.y-position.y)**2)
		else:
			distance_to_player2 = 4095
		if bot2_pos is Vector2:
			distance_to_bot2 = sqrt((bot2_pos.x-position.x)**2+(bot2_pos.y-position.y)**2)
		else:
			distance_to_bot2 = 4095
		if distance_to_player1 < distance_to_player2 and distance_to_player1 < distance_to_bot2:
			navigation_agent.target_position = player1_pos
			if distance_to_player1 < 70:
				bot_attack_or_guard_input = 1
			elif distance_to_player1 < 100:
				bot_attack_or_guard_input = -1
			else:
				bot_attack_or_guard_input = 0
		elif distance_to_player2 < distance_to_bot2:
			navigation_agent.target_position = player2_pos
			if distance_to_player2 < 70:
				bot_attack_or_guard_input = 1
			elif distance_to_player2 < 100:
				bot_attack_or_guard_input = -1
			else:
				bot_attack_or_guard_input = 0
		else:
			navigation_agent.target_position = bot2_pos
			if distance_to_bot2 < 70:
				bot_attack_or_guard_input = 1
			elif distance_to_bot2 < 100:
				bot_attack_or_guard_input = -1
			else:
				bot_attack_or_guard_input = 0

################ STATE FUNCTIONS ################
func _idle_state(delta) -> void:
	var input = bot_movement_input
	_movement(delta, input, speed)
	if _hp_control():
		enter_dead_state()
	if velocity != Vector2(0, 0):
		_enter_run_state()
	if bot_attack_or_guard_input == 1:
		_enter_attack_state()
	elif bot_attack_or_guard_input == -1:
		_enter_guard_state()
	elif bot_attack_or_guard_input == 0 and dash and can_dash:
		_enter_dash_state()

func _run_state(delta) -> void:
	var input = bot_movement_input
	_movement(delta, input, speed)
	if _hp_control():
		enter_dead_state()
	if velocity == Vector2(0, 0):
		enter_idle_state()
	if bot_attack_or_guard_input == 1:
		_enter_attack_state()
	elif bot_attack_or_guard_input == -1:
		_enter_guard_state()
	elif bot_attack_or_guard_input == 0 and dash and can_dash:
		_enter_dash_state()

func _attack_state(delta) -> void:
	var input = bot_movement_input
	_movement(delta, input, ATTACK_MOVEMENT_DEBUFF*speed)
	if body_inside_attack >= 1 and can_attack and attack_ongoing:
		can_attack = false
		for body in attacked_body:
			if body is House or body is Tower:
				if team != body.team:
					body.destroy()
			elif (body.layer1 and layer1) or (body.layer2 and layer2) or (body.layer3 and layer3):
				if not body.guard_ongoing:
					body.hp -= damage
				elif body.deflect:
					hp -= 0.25*damage
	if _hp_control():
		enter_dead_state()
	if not attack_ongoing:
		if velocity == Vector2(0,0):
			enter_idle_state()
		else:
			_enter_run_state()
	if bot_attack_or_guard_input == -1:
		_enter_guard_state()
	elif bot_attack_or_guard_input == 0 and dash and can_dash:
		_enter_dash_state()


func _guard_state(delta) -> void:
	var input = bot_movement_input
	_movement(delta, input, GUARD_MOVEMENT_DEBUFF*speed)
	if _hp_control():
		enter_dead_state()
	if not guard_ongoing:
		if velocity == Vector2(0,0):
			enter_idle_state()
		else:
			_enter_run_state()

func _dash_state(delta) -> void:
	move_and_slide()
	if _hp_control():
		enter_dead_state()
	if not dash_ongoing:
		velocity /= 4
		if velocity == Vector2(0,0):
			enter_idle_state()
		else:
			_enter_run_state()

func _dead_state(delta) -> void:
	pass


################ ENTER STATE FUNCTIONS ###############
func enter_idle_state() -> void:
	state = IDLE
	anim.play("idle")

func _enter_run_state() -> void:
	state = RUN
	anim.play("run")

func _enter_attack_state() -> void:
	state = ATTACK
	attack_ongoing = true
	attack_timer.start()
	anim.play("attack")
	$AudioStreamPlayer2.play()

func _enter_guard_state() -> void:
	state = GUARD
	guard_ongoing = true
	guard_timer.start()
	if deflect:
		anim.play("deflect")
	else:
		anim.play("guard")

func _enter_dash_state() -> void:
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

func enter_dead_state() -> void:
	state = DEAD
	anim.play("death")
	$AudioStreamPlayer.play()
	await anim.animation_finished
	dead = true
	emit_signal("bot1_dead")
	global_position = Vector2(-2000,-2000)
	velocity = Vector2(0,0)


############# Other shit ###########
func _on_attack_area_body_entered(body: Node2D) -> void:
	body_inside_attack += 1
	attacked_body.append(body)

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


func heal():
	heal_effect.show()
	anim2.play("heal")
	await anim2.animation_finished
	heal_effect.hide()
