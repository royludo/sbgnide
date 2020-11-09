extends Button

func _toggled(button_pressed):
	if button_pressed:
		Globals.currentMouseMode = Globals.MouseMode.SELECT
