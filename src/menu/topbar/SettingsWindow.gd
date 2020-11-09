extends WindowDialog

var config:ConfigFile = Globals.config
onready var javaPathField = $MarginContainer/CenterContainer/VBoxContainer/GridContainer/JavaPathField
onready var libsbgnPathField = $MarginContainer/CenterContainer/VBoxContainer/GridContainer/LibSBGNPathField
onready var gitPathField = $MarginContainer/CenterContainer/VBoxContainer/GridContainer/GitPathField

onready var javaStatusLabel = $MarginContainer/CenterContainer/VBoxContainer/GridContainer/JavaStatusLabel
onready var sbgnBackendStatusLabel = $MarginContainer/CenterContainer/VBoxContainer/GridContainer/LibSBGNStatusLabel2
onready var gitStatusLabel = $MarginContainer/CenterContainer/VBoxContainer/GridContainer/GitStatusLabel

onready var messageLabel = $MarginContainer/CenterContainer/VBoxContainer/MessageLabel

const JavaCheckClass = preload("res://src/thirdpartytools/JavaCheck.gd")
const GitCheckClass = preload("res://src/thirdpartytools/GitCheck.gd")
const SbgnBackendCheckClass = preload("res://src/thirdpartytools/SbgnBackendCheck.gd")

# Called when the node enters the scene tree for the first time.
func _ready():
	ConfigurationEvents.connect("java_not_working", self, "_on_java_not_working")
	ConfigurationEvents.connect("java_successfully_tested", self, "_on_java_successfully_tested")
	ConfigurationEvents.connect("git_not_working", self, "_on_git_not_working")
	ConfigurationEvents.connect("git_successfully_tested", self, "_on_git_successfully_tested")
	ConfigurationEvents.connect("sbgn_backend_not_working", self, "_on_sbgn_backend_not_working")
	ConfigurationEvents.connect("sbgn_backend_successfully_tested", self, "_on_sbgn_backend_successfully_tested")

	var javaCheck = JavaCheckClass.new()
	var gitCheck = GitCheckClass.new()
	var sbgnBackendCheck = SbgnBackendCheckClass.new()
	

func _on_SaveButton_pressed():
	
	## write values in config file ##
	config.set_value("libSBGN", "javaPath", javaPathField.text)
	config.set_value("libSBGN", "libSBGNPath", libsbgnPathField.text)
	config.set_value("git", "gitPath", gitPathField.text)
	
	config.save(Globals.DEFAULT_CONFIG_PATH)
	
	pass # Replace with function body.


func _on_CloseButton_pressed():
	set_visible(false)


func _on_JavaPathFileDialogButton_pressed():
	$FileDialog.filters = PoolStringArray(["*.exe"])
	
	if javaPathField.text != null and not javaPathField.text.empty():
		$FileDialog.current_path = javaPathField.text.get_basename()
	
	if not $FileDialog.is_connected("file_selected", self, "_on_JavaPath_selected"):
		$FileDialog.connect("file_selected", self, "_on_JavaPath_selected")
	$FileDialog.popup_centered()


func _on_JavaPath_selected(path:String):
	javaPathField.text = path
	if $FileDialog.is_connected("file_selected", self, "_on_JavaPath_selected"):
		$FileDialog.disconnect("file_selected", self, "_on_JavaPath_selected")
	ConfigurationEvents.emit_signal("java_path_changed", path)


func _on_LibSBGNPathLabelFileDialogButton_pressed():
	$FileDialog.filters = PoolStringArray(["*.jar"])
	
	if libsbgnPathField.text != null and not libsbgnPathField.text.empty():
		$FileDialog.current_path = libsbgnPathField.text.get_basename()
	
	if not $FileDialog.is_connected("file_selected", self, "_on_LibSBGNPath_selected"):
		$FileDialog.connect("file_selected", self, "_on_LibSBGNPath_selected")
	$FileDialog.popup_centered()


func _on_LibSBGNPath_selected(path:String):
	libsbgnPathField.text = path
	if $FileDialog.is_connected("file_selected", self, "_on_LibSBGNPath_selected"):
		$FileDialog.disconnect("file_selected", self, "_on_LibSBGNPath_selected")
	ConfigurationEvents.emit_signal("sbgn_backend_path_changed", path)


func _on_GitPathFileDialogButton_pressed():
	
	if gitPathField.text != null and not gitPathField.text.empty():
		$FileDialog.current_path = gitPathField.text.get_basename()
	
	if not $FileDialog.is_connected("file_selected", self, "_on_GitPath_selected"):
		$FileDialog.connect("file_selected", self, "_on_GitPath_selected")
	$FileDialog.popup_centered()


func _on_GitPath_selected(path:String):
	gitPathField.text = path
	if $FileDialog.is_connected("file_selected", self, "_on_GitPath_selected"):
		$FileDialog.disconnect("file_selected", self, "_on_GitPath_selected")
	ConfigurationEvents.emit_signal("git_path_changed", path)


func _on_java_not_working(msg):
	javaStatusLabel.modulate = Color.red
	javaStatusLabel.text = "X"
	messageLabel.modulate = Color.red
	messageLabel.text = msg
	Globals.is_java_working = false
	

func _on_java_successfully_tested():
	javaStatusLabel.modulate = Color.green
	javaStatusLabel.text = "OK"
	messageLabel.text = ""
	Globals.is_java_working = true


func _on_git_not_working(msg):
	gitStatusLabel.modulate = Color.red
	gitStatusLabel.text = "X"
	messageLabel.modulate = Color.red
	messageLabel.text = msg
	Globals.is_git_working = false
	

func _on_git_successfully_tested():
	gitStatusLabel.modulate = Color.green
	gitStatusLabel.text = "OK"
	messageLabel.text = ""
	Globals.is_git_working = true


func _on_sbgn_backend_not_working(msg):
	sbgnBackendStatusLabel.modulate = Color.red
	sbgnBackendStatusLabel.text = "X"
	messageLabel.modulate = Color.red
	messageLabel.text = msg
	Globals.is_sbgn_backend_configured = false
	

func _on_sbgn_backend_successfully_tested():
	sbgnBackendStatusLabel.modulate = Color.green
	sbgnBackendStatusLabel.text = "OK"
	messageLabel.text = ""
	Globals.is_sbgn_backend_configured = true



