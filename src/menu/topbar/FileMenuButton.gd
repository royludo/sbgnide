extends MenuButton

signal start_backend_server()
signal show_openfiledialog()


# Called when the node enters the scene tree for the first time.
func _ready():
	var popup = get_popup()
	popup.connect("id_pressed", self, "_on_FileMenu_select")


func _on_FileMenu_select(id:int):
	match id:
		0: # Start backend
			emit_signal("start_backend_server")
		1: # Open
			$OpenFileDialog.current_dir = "C:/Programmation/Java/Projects/uberlibsbgn/samples"
			$OpenFileDialog.popup_centered()
		2: # New Project
			$NewProjectFileDialog.popup_centered()
		3: # Save
			pass
	pass
