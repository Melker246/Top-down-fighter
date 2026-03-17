extends CanvasLayer

@onready var audio: AudioStreamPlayer = $AudioStreamPlayer

func _ready() -> void:
	audio.play()
	process_mode = Node.PROCESS_MODE_ALWAYS

func _on_button_pressed() -> void:
	get_parent().toggle_pause()
	MenuManager.start()
	hide()

func _on_button_2_pressed() -> void:
	MenuManager.quit()

func _on_button_3_pressed() -> void:
	get_parent().toggle_pause()
	audio.stream_paused = true
