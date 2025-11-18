extends CharacterBody2D

signal bot1_dead

const MAX_SPEED = 300
const ACC = 800
const ATTACK_MOVEMENT_DEBUFF = 0.8
const GUARD_MOVEMENT_DEBUFF = 0.2

@onready var attack_timer: Timer = $AttackTimer
@onready var guard_timer: Timer = $GuardTimer
@onready var anim: AnimationPlayer = $AnimationPlayer
@onready var sprite: Sprite2D = $Sprite2D
@onready var attack_area: Area2D = $AttackArea

var bot_movement_input = Vector2(0,0)
var bot_attack_or_guard_input = 0

var hp = 100
var team = 3

var attack_ongoing = false
var attack_area_base_x_pos = 0
var body_inside_attack = false
var attacked_body = 0
var can_attack = true
var guard_ongoing = false

enum {IDLE, RUN, ATTACK, GUARD, DEAD}
var state = IDLE

func _ready() -> void:
	anim.play("idle")
	attack_area_base_x_pos = attack_area.position.x

################# STATE MACHINE #################
func _physics_process(delta: float) -> void:
	match state:
		IDLE:
			_idle_state(delta)
		RUN:
			_run_state(delta)
		ATTACK:
			_attack_state(delta)
		GUARD:
			_guard_state(delta)
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
	var input = bot_movement_input
	_movement(delta, input, 1)
	if _hp_control():
		enter_dead_state()
	if velocity != Vector2(0, 0):
		_enter_run_state()
	if bot_attack_or_guard_input == 1:
		_enter_attack_state()
	if bot_attack_or_guard_input == -1:
		_enter_guard_state()

func _run_state(delta) -> void:
	var input = bot_movement_input
	_movement(delta, input, 1)
	if _hp_control():
		enter_dead_state()
	if velocity == Vector2(0, 0):
		_enter_idle_state()
	if bot_attack_or_guard_input == 1:
		_enter_attack_state()
	if bot_attack_or_guard_input == -1:
		_enter_guard_state()

func _attack_state(delta) -> void:
	var input = bot_movement_input
	_movement(delta, input, ATTACK_MOVEMENT_DEBUFF)
	if body_inside_attack and can_attack and attack_ongoing:
		can_attack = false
		if attacked_body is House:
			attacked_body.queue_free()
		else:
			if not attacked_body.guard_ongoing:
				attacked_body.hp -= 50
	if _hp_control():
		enter_dead_state()
	if not attack_ongoing:
		if velocity == Vector2(0,0):
			_enter_idle_state()
		else:
			_enter_run_state()
	if bot_attack_or_guard_input == -1:
		_enter_guard_state()


func _guard_state(delta) -> void:
	var input = bot_movement_input
	_movement(delta, input, GUARD_MOVEMENT_DEBUFF)
	if _hp_control():
		enter_dead_state()
	if not guard_ongoing:
		if velocity == Vector2(0,0):
			_enter_idle_state()
		else:
			_enter_run_state()

func _dead_state(delta) -> void:
	pass


################ ENTER STATE FUNCTIONS ###############
func _enter_idle_state() -> void:
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
	anim.play("guard")

func enter_dead_state() -> void:
	state = DEAD
	anim.play("death")
	await anim.animation_finished
	emit_signal("bot1_dead")
	queue_free()


func _on_attack_area_body_entered(body: Node2D) -> void:
	body_inside_attack = true
	attacked_body = body

func _on_attack_area_body_exited(body: Node2D) -> void:
	body_inside_attack = false
	attacked_body = 0

func _on_attack_timer_timeout() -> void:
	attack_ongoing = false
	can_attack = true

func _on_guard_timer_timeout() -> void:
	guard_ongoing = false
