extends CanvasLayer

@onready var audio: AudioStreamPlayer = $AudioStreamPlayer

func _ready() -> void:
	audio.play() #play music
	process_mode = Node.PROCESS_MODE_ALWAYS #always process this node even if paused

func _on_button_pressed() -> void: #when the start button is pressed the game unpauses and the scene changes to start menu
	get_parent().toggle_pause()
	MenuManager.start()
	hide()

func _on_button_2_pressed() -> void: #quit the game
	MenuManager.quit()

func _on_button_3_pressed() -> void: #Resume the game by getting the parent (menu_manager) and toggle pause so the game can continue
	get_parent().toggle_pause()
	audio.stream_paused = true
