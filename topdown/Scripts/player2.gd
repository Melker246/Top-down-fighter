extends CharacterBody2D

const MAX_SPEED = 300
const ACC = 800

@onready var attack_timer: Timer = $AttackTimer
@onready var anim: AnimationPlayer = $AnimationPlayer
@onready var sprite: Sprite2D = $Sprite2D
@onready var attack_area: Area2D = $AttackArea

var attack_ongoing = false
var attack_area_base_x_pos = 0
var body_inside_attack = false
var attacked_body = 0

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
func _movement(delta, input) -> void:
	if input.x != 0 and input.y != 0:
		var pythagorean = 1/sqrt(input.x**2 + input.y**2)
		input = input * pythagorean
	velocity.x = move_toward(velocity.x, input.x*MAX_SPEED, ACC*delta)
	velocity.y = move_toward(velocity.y, input.y*MAX_SPEED, ACC*delta)
	move_and_slide()
	if velocity.x < 0:
		sprite.flip_h = true
		attack_area.position.x = attack_area_base_x_pos*-1
	elif velocity.x > 0:
		sprite.flip_h = false
		attack_area.position.x = attack_area_base_x_pos

################ STATE FUNCTIONS ################
func _idle_state(delta) -> void:
	var input = Vector2(0, 0)
	input.y = Input.get_axis("up2", "down2")
	input.x = Input.get_axis("left2", "right2")
	_movement(delta, input)
	if velocity != Vector2(0, 0):
		_enter_run_state()
	if Input.is_action_just_pressed("attack2"):
		_enter_attack_state()

func _run_state(delta) -> void:
	var input = Vector2(0, 0)
	input.y = Input.get_axis("up2", "down2")
	input.x = Input.get_axis("left2", "right2")
	_movement(delta, input)
	if velocity == Vector2(0, 0):
		_enter_idle_state()
	if Input.is_action_just_pressed("attack2"):
		_enter_attack_state()

func _attack_state(delta) -> void:
	var input = Vector2(0, 0)
	input.y = Input.get_axis("up2", "down2")
	input.x = Input.get_axis("left2", "right2")
	_movement(delta, input)
	if body_inside_attack:
		attacked_body.enter_dead_state()
		body_inside_attack = false
	if not attack_ongoing:
		if velocity == Vector2(0,0):
			_enter_idle_state()
		else:
			_enter_run_state()
	

func _guard_state(delta) -> void:
	pass

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
	pass

func enter_dead_state() -> void:
	print("2död")


func _on_attack_area_body_entered(body: Node2D) -> void:
	body_inside_attack = true
	attacked_body = body

func _on_attack_area_body_exited(body: Node2D) -> void:
	body_inside_attack = false
	attacked_body = 0

func _on_attack_timer_timeout() -> void:
	attack_ongoing = false
