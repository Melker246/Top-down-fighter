extends CanvasLayer

signal health_button_pressed
signal attack_button_pressed
signal speed_button_pressed
signal team_button_pressed

@onready var health_button: Button = $HBoxContainer/HealthButton
@onready var attack_button: Button = $HBoxContainer/AttackButton
@onready var speed_button: Button = $HBoxContainer/SpeedButton
@onready var team_button: Button = $HBoxContainer/TeamButton
@onready var label: Label = $Label

var player_chosing = 1

func update_text(p1heal_upg, p1atta_upg, p1spee_upg, p1team_upg, p2heal_upg, p2atta_upg, p2spee_upg, p2team_upg):
	if player_chosing % 2 == 1:
		if p1heal_upg == 1:
			health_button.text = "Health
			+monk
			next 
			+40% hp"
		elif p1heal_upg >= 2:
			health_button.text = "Health
			+40% hp
			next 
			+40% hp"
		else:
			health_button.text = "Health
			+50% hp
			next 
			+monk"
		if p1atta_upg == 1:
			attack_button.text = "Attack
			+deflect
			next 
			+30% dmg"
		elif p1atta_upg >= 2:
			attack_button.text = "Attack
			+30% dmg
			next 
			+30% dmg"
		else:
			attack_button.text = "Attack
			+50% dmg
			next 
			+deflect"
		if p1spee_upg == 1:
			speed_button.text = "Speed
			+dash
			next
			+10% speed"
		elif p1spee_upg >= 2:
			speed_button.text = "Speed
			+10% speed
			next 
			+10% speed"
		else:
			speed_button.text = "Speed
			+20% speed
			next 
			+dash"
		if p1team_upg >= 1:
			if p1team_upg % 2 == 0:
				team_button.text = "Team
				+nothing
				next 
				+lancer"
			else:
				team_button.text = "Team
				+lancer
				next 
				+nothing"
		else:
			team_button.text = "Team
				+archer tower
				next 
				+lancer"
	else:
		if p2heal_upg == 1:
			health_button.text = "Health
			+monk
			next 
			+40% hp"
		elif p2heal_upg >= 2:
			health_button.text = "Health
			+40% hp
			next 
			+40% hp"
		else:
			health_button.text = "Health
			+50% hp
			next 
			+monk"
		if p2atta_upg == 1:
			attack_button.text = "Attack
			+deflect
			next 
			+30% dmg"
		elif p2atta_upg >= 2:
			attack_button.text = "Attack
			+30% dmg
			next 
			+30% dmg"
		else:
			attack_button.text = "Attack
			+50% dmg
			next 
			+deflect"
		if p2spee_upg == 1:
			speed_button.text = "Speed
			+dash
			next
			+10% speed"
		elif p2spee_upg >= 2:
			speed_button.text = "Speed
			+10% speed
			next 
			+10% speed"
		else:
			speed_button.text = "Speed
			+20% speed
			next 
			+dash"
		if p2team_upg >= 1:
			if p2team_upg % 2 == 0:
				team_button.text = "Team
				+nothing
				next 
				+lancer"
			else:
				team_button.text = "Team
				+lancer
				next 
				+nothing"
		else:
			team_button.text = "Team
				+archer tower
				next 
				+lancer"





func _on_health_button_pressed() -> void:
	player_chosing += 1
	emit_signal("health_button_pressed")
	if player_chosing % 2 == 1:
		label.text = " Blue Player"
	else:
		label.text = "Yellow Player"

func _on_attack_button_pressed() -> void:
	player_chosing += 1
	emit_signal("attack_button_pressed")
	if player_chosing % 2 == 1:
		label.text = " Blue Player"
	else:
		label.text = "Yellow Player"

func _on_speed_button_pressed() -> void:
	player_chosing += 1
	emit_signal("speed_button_pressed")
	if player_chosing % 2 == 1:
		label.text = " Blue Player"
	else:
		label.text = "Yellow Player"

func _on_team_button_pressed() -> void:
	player_chosing += 1
	emit_signal("team_button_pressed")
	if player_chosing % 2 == 1:
		label.text = " Blue Player"
	else:
		label.text = "Yellow Player"
