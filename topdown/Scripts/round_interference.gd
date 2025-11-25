extends CanvasLayer

signal health_button_pressed
signal attack_button_pressed
signal speed_button_pressed
signal team_button_pressed

func _on_health_button_pressed() -> void:
	emit_signal("health_button_pressed")

func _on_attack_button_pressed() -> void:
	emit_signal("attack_button_pressed")

func _on_speed_button_pressed() -> void:
	emit_signal("speed_button_pressed")

func _on_team_button_pressed() -> void:
	emit_signal("team_button_pressed")
