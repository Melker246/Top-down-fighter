extends CharacterBody2D

const MAX_SPEED = 300
const ACC = 400

enum {IDLE, RUN, ATTACK, GUARD, DEAD}
var state = IDLE


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

################ STATE FUNCTIONS ################
func _idle_state(delta) -> void:
	var input = Vector2(0, 0)
	input.y = Input.get_axis("up", "down")
	input.x = Input.get_axis("left", "right")
	_movement(delta, input)
	if velocity != Vector2(0, 0):
		_enter_run_state()

func _run_state(delta) -> void:
	var input = Vector2(0, 0)
	input.y = Input.get_axis("up", "down")
	input.x = Input.get_axis("left", "right")
	_movement(delta, input)
	if velocity == Vector2(0, 0):
		_enter_idle_state()

func _attack_state(delta) -> void:
	pass

func _guard_state(delta) -> void:
	pass

func _dead_state(delta) -> void:
	pass


################ ENTER STATE FUNCTIONS ###############
func _enter_idle_state() -> void:
	state = IDLE

func _enter_run_state() -> void:
	state = RUN

func _enter_attack_state() -> void:
	pass

func _enter_guard_state() -> void:
	pass

func _enter_dead_state() -> void:
	pass
