extends StaticBody2D

class_name Tower

const ARROW_SCENE = preload("res://Scenes/arrow.tscn")

signal dead

@onready var anim: AnimationPlayer = $AnimationPlayer
@onready var tower: Sprite2D = $Tower
@onready var archer: Sprite2D = $Archer
@onready var collishon_shape: CollisionShape2D = $CollisionShape2D
@onready var shoot_timer: Timer = $ShootTimer
@onready var shoot_anim_offset: Timer = $ShootAnimationOffset

var team = 0
var can_shoot = true

func shoot_players(player1,player2,player3):
	if (player1.position-position).length() < 300 or (player2.position-position).length() < 300 or (player3.position-position).length() < 300:
		var closest_target = null
		shoot_timer.start()
		shoot_anim_offset.start()
		can_shoot = false
		anim.play("blue_shoot")
		if (player1.position-position).length() < (player2.position-position).length() and (player1.position-position).length() < (player3.position-position).length():
			closest_target = player1
		elif (player2.position-position).length() < (player3.position-position).length():
			closest_target = player2
		else:
			closest_target = player3
		await shoot_anim_offset.timeout
		var arrow = ARROW_SCENE.instantiate()
		add_child(arrow)
		arrow.team = team
		arrow.position = Vector2(5,-124)
		arrow.target_pos = closest_target.position

func destroy():
	emit_signal("dead", team)
	hide()
	collishon_shape.disabled = true

func rebuild():
	show()
	collishon_shape.disabled = false

func blue() -> void:
	anim.play("blue")
	team = 1

func yellow() -> void:
	anim.play("yellow")
	team = 2

func black() -> void:
	anim.play("black")
	team = 3

func red() -> void:
	anim.play("red")
	team = 4


func _on_shoot_timer_timeout() -> void:
	can_shoot = true
