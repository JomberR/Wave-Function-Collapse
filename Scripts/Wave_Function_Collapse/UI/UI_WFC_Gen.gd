extends CanvasLayer

signal generate_wave_function

func _on_generate_pressed():
	emit_signal("generate_wave_function")

func _on_exit_pressed():
	get_tree().quit()
