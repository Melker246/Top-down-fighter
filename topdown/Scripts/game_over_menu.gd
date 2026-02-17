extends CanvasLayer

func _on_button_pressed() -> void:
	MenuManager.start()
	hide()


func _on_button_2_pressed() -> void:
	MenuManager.quit()
