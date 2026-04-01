extends CharacterBody2D

const SPEED = 200

#The team the arrow is on, used to make sure the player on the same team can not take damage
var team = 0

#Variables for getting to the position of the target
var target_pos = Vector2(0,0)
var dir = Vector2(0,0)

func _physics_process(delta: float) -> void:
	if (target_pos - global_position).length() > 5:
		dir = target_pos  - global_position
		rotation = atan2(dir.y, dir.x)
		velocity = (dir/sqrt(dir.x**2+dir.y**2))*SPEED
		move_and_slide()
	#if the target is further away than 5 px the arrow moves towards the target it was given once it was instaciated

func _on_timer_timeout() -> void: #After a while the arrow despawns as to not make it a mine on the map
	queue_free()

func _on_area_2d_body_entered(body: Node2D) -> void:
	if not body.team == team:
		body.hp -= 25
		queue_free()
#Deals damage to the target if it collides and the target isn't on the same team
