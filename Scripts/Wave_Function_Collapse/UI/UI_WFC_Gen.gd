extends CanvasLayer

signal generate_wave_function()
signal change_map_size(value: int, dimension: String)

func _on_generate_pressed():
	generate_wave_function.emit()

func _on_exit_pressed():
	get_tree().quit()

func _on_width_value_changed(value):
	change_map_size.emit(int(value), "x")

func _on_height_value_changed(value):
	change_map_size.emit(int(value), "y")
