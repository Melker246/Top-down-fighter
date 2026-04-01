extends CanvasLayer


func _ready() -> void:
	$AnimationPlayer.play("idle")

func _on_button_pressed() -> void: #when the button is pressed start the level
	MenuManager.start_level()
	hide()
