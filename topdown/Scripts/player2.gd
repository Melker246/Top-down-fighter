extends CharacterBody2D

signal player2_dead

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

enum {IDLE, RUN, ATTACK, GUARD, DASH, DEAD}
var state = IDLE

func _ready() -> void:
	anim.play("idle")
	attack_area_base_x_pos = attack_area.position.x

################# STATE MACHINE #################
func _physics_process(delta: float) -> void:
	if not dead:
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

################ HELP FUNCTIONS
func _movement(delta, input, speedkoefficent) -> void:
	if input.x != 0 and input.y != 0:
		var pythagorean = 1/sqrt(input.x**2 + input.y**2)
		input = input * pythagorean
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

################ STATE FUNCTIONS ################
func _idle_state(delta) -> void:
	var input = Vector2(0, 0)
	input.y = Input.get_axis("up2", "down2")
	input.x = Input.get_axis("left2", "right2")
	_movement(delta, input, speed)
	if _hp_control():
		enter_dead_state()
	if velocity != Vector2(0, 0):
		_enter_run_state()
	if Input.is_action_just_pressed("attack2"):
		_enter_attack_state()
	elif Input.is_action_just_pressed("guard2"):
		_enter_guard_state()
	elif Input.is_action_just_pressed("dash2") and dash and can_dash:
		_enter_dash_state()


func _run_state(delta) -> void:
	var input = Vector2(0, 0)
	input.y = Input.get_axis("up2", "down2")
	input.x = Input.get_axis("left2", "right2")
	_movement(delta, input, speed)
	if _hp_control():
		enter_dead_state()
	if velocity == Vector2(0, 0):
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
	_movement(delta, input, ATTACK_MOVEMENT_DEBUFF*speed)
	if body_inside_attack >= 1 and can_attack and attack_ongoing:
		can_attack = false
		for body in attacked_body:
			if body is House or body is Tower:
				if team != body.team:
					body.destroy()
			else:
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
	if Input.is_action_just_pressed("guard2"):
		_enter_guard_state()
	elif Input.is_action_just_pressed("dash2") and dash and can_dash:
		_enter_dash_state()



func _guard_state(delta) -> void:
	var input = Vector2(0, 0)
	input.y = Input.get_axis("up2", "down2")
	input.x = Input.get_axis("left2", "right2")
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
	dash_ongoing = true
	can_dash = false
	dash_cooldown.start()
	dash_timer.start()

func enter_dead_state() -> void:
	state = DEAD
	anim.play("death")
	await anim.animation_finished
	dead = true
	emit_signal("player2_dead")
	global_position = Vector2(-1000,-2000)
	velocity = Vector2(0,0)


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
