extends MenuButton

signal show_settings()

# Called when the node enters the scene tree for the first time.
func _ready():
	var popup = get_popup()
	popup.connect("id_pressed", self, "_on_EditMenu_select")


func _on_EditMenu_select(id:int):
	match id:
		0: # Configuration
			emit_signal("show_settings")
	
	pass

func init_config_fields(settingsWindow:Popup):
	
	var javaPathConfigValue = Globals.config.get_value("libSBGN", "javaPath", "")
	var libSBGNPathConfigValue = Globals.config.get_value("libSBGN", "libSBGNPath", "")
	var gitPathConfigValue = Globals.config.get_value("git", "gitPath", "")
	
	settingsWindow.get_node("MarginContainer/CenterContainer/VBoxContainer/GridContainer/JavaPathField")\
		.text = javaPathConfigValue
	ConfigurationEvents.emit_signal("java_path_changed", javaPathConfigValue)
	
	settingsWindow.get_node("MarginContainer/CenterContainer/VBoxContainer/GridContainer/LibSBGNPathField")\
		.text = libSBGNPathConfigValue
	ConfigurationEvents.emit_signal("sbgn_backend_path_changed", libSBGNPathConfigValue)
	
	settingsWindow.get_node("MarginContainer/CenterContainer/VBoxContainer/GridContainer/GitPathField")\
		.text = gitPathConfigValue
	ConfigurationEvents.emit_signal("git_path_changed", gitPathConfigValue)
