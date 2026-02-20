extends CanvasLayer


func _ready() -> void:
	$AnimationPlayer.play("idle")

func _on_button_pressed() -> void:
	MenuManager.start()
	hide()
