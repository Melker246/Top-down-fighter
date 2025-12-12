extends CharacterBody2D

const SPEED = 200

var team = 0
var target_pos = Vector2(0,0)
var dir = Vector2(0,0)

func _physics_process(delta: float) -> void:
	if (target_pos + Vector2(0,-32) - global_position).length() > 5:
		dir = target_pos + Vector2(0,-32) - global_position
		rotation = atan2(dir.y, dir.x)
		velocity = (dir/sqrt(dir.x**2+dir.y**2))*SPEED
		move_and_slide()

func _on_timer_timeout() -> void:
	queue_free()

func _on_area_2d_body_entered(body: Node2D) -> void:
	if not body.team == team:
		body.hp -= 25
		queue_free()
