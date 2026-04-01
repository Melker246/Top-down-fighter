extends CanvasLayer

func _ready() -> void:
	if Globals.blue_wins > Globals.black_wins and Globals.blue_wins > Globals.yellow_wins and Globals.blue_wins > Globals.red_wins:
		$Label.text = "Blue Wins"
	elif Globals.black_wins > Globals.blue_wins and Globals.black_wins > Globals.yellow_wins and Globals.black_wins > Globals.red_wins:
		$Label.text = "Blue Wins"
	elif Globals.red_wins > Globals.black_wins and Globals.red_wins > Globals.yellow_wins and Globals.red_wins > Globals.blue_wins:
		$Label.text = "Blue Wins"
	elif Globals.yellow_wins > Globals.black_wins and Globals.yellow_wins > Globals.blue_wins and Globals.yellow_wins > Globals.red_wins:
		$Label.text = "Blue Wins"
#Display who wins

func _on_button_pressed() -> void: #When the start button is pressed, call the start function in menu manager to go back to the start menu to then restart the game
	MenuManager.start()
	hide()

func _on_button_2_pressed() -> void: #When quit button is pressed close down the game
	MenuManager.quit()
