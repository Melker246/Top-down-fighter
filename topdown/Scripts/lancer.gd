extends CharacterBody2D

const MAX_SPEED = 300
const ACC = 800

@onready var sprite: Sprite2D = $Sprite2D
@onready var attack_area: Area2D = $AttackArea
@onready var player_detecter: Area2D = $PlayerDetecter
@onready var anim: AnimationPlayer = $AnimationPlayer

var team = 0

var hp = 25
var damage = 25

var target_players_positions = []
var targets_inside_area = 0
var player_position = Vector2(0,0)

func setup():
	set_collision_layer_value(team+1,true)
	set_collision_mask_value(team+1,false)
	attack_area.set_collision_mask_value(team+1,false)
	player_detecter.set_collision_mask_value(team+1,false)

func _physics_process(delta: float) -> void:
	if targets_inside_area > 0:
		var closest_target_pos = target_players_positions[0] - global_position
		for pos in target_players_positions:
			if (pos - global_position).length() < closest_target_pos.length():
				closest_target_pos = pos - global_position
		if closest_target_pos.length() > 30:
			_movement(closest_target_pos, delta)
	else:
		var target_pos = player_position - global_position
		if target_pos.length() > 30:
			_movement(target_pos, delta)

func _movement(target, delta):
	if target.x != 0 and target.y != 0:
		var pythagorean = 1/sqrt(target.x**2 + target.y**2)
		target = target * pythagorean
	velocity.x = move_toward(velocity.x, target.x*MAX_SPEED, ACC*delta)
	velocity.y = move_toward(velocity.y, target.y*MAX_SPEED, ACC*delta)
	move_and_slide()
	if velocity.x < 0:
		sprite.flip_h = true
	elif velocity.x > 0:
		sprite.flip_h = false

func _on_player_detecter_body_entered(body: Node2D) -> void:
	if body.team != team:
		targets_inside_area += 1
		target_players_positions.append(body.global_position)

func _on_player_detecter_body_exited(body: Node2D) -> void:
	if body.team != team:
		targets_inside_area -= 1
		target_players_positions.erase(body.global_position)
