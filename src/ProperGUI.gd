extends Control

var config:ConfigFile = Globals.config as ConfigFile
var default_config:ConfigFile = ConfigFile.new()
var keepalive_thread
var keepalive_semaphore
var keepalive_mutex
var keepalive = true
onready var sbgnserver = $SBGNServer
const nodeTestScene = preload("res://src/mapelements/NodeTest.tscn")
onready var mapViewContainer = $VBoxContainer/PanelContainer2/TabContainer/MapView
onready var settingsWindows = $CanvasLayer/SettingsWindow
onready var addGlyphDialog = $CanvasLayer/AddGlyphDialog
onready var logDisplay := $VBoxContainer/PanelContainer3/BottomBar/HBoxContainer/LogDisplay

const GitInterfaceClass = preload("res://src/thirdpartytools/GitInterface.gd")

func _ready():
	
	# connect logdisplay to log signals from globalEvents
	GlobalEvents.connect("log_msg", logDisplay, "add_msg")
	GlobalEvents.connect("log_warning", logDisplay, "add_warning")
	GlobalEvents.connect("log_error", logDisplay, "add_error")
	
	## load config ##
	var err = config.load(Globals.DEFAULT_CONFIG_PATH)
	if err != OK:
		#pb with config, we use default config instead
		var err2 = default_config.load("res://default_settings.conf")
		if err2 != OK:
			print("Unable to open default config file that should be shipped with the application")
		else:
			default_config.save(Globals.DEFAULT_CONFIG_PATH)
			var err3 = config.load(Globals.DEFAULT_CONFIG_PATH)
			if err3 != OK:
				print("Also big screw up here")
		
	# at this point we are sure to have a config file
	Globals.config = config
	
	# init keepalive thread related stuff
	keepalive_mutex = Mutex.new()
	keepalive_semaphore = Semaphore.new()
	
	# defer setting fields init to editmenubutton script
	$VBoxContainer/PanelContainer/TopMenu/HBoxContainer/EditMenuButton.init_config_fields(settingsWindows)
	
	start_backend_sbgnserver()
	
	pass # Replace with function body.


func _on_EditMenuButton_show_settings():
	settingsWindows.set_as_minsize()
	settingsWindows.popup_centered_minsize()
	pass # Replace with function body.

func start_backend_sbgnserver():
	
	
	var javaPath = config.get_value("libSBGN", "javaPath")
	var libsbgnjarpath = config.get_value("libSBGN", "libSBGNPath")
	sbgnserver.constructor(javaPath, libsbgnjarpath)
	sbgnserver.start()
	start_keepalive_thread()
	
	
	
	pass


func _on_FileMenuButton_start_backend_server():
	start_backend_sbgnserver()
	pass # Replace with function body.

func start_keepalive_thread():
	keepalive_thread = Thread.new()
	keepalive_thread.start(self, "keep_backend_alive")
	
	pass

func keep_backend_alive(_userdata):
	while true:
		print("keepalive thread before semaphore")
		keepalive_semaphore.wait() # Wait until posted.
		print("keepalive AFTER before semaphore")

		keepalive_mutex.lock()
		var local_keepalive = keepalive # Protect with Mutex.
		keepalive_mutex.unlock()

		if not local_keepalive:
			sbgnserver.shutdown()
			break
		
		print("keepalive thread SEND keepalive")
		sbgnserver.keepalive()


func stop_keepalive_thread():
	# Set exit condition to true.
	keepalive_mutex.lock()
	keepalive = false
	keepalive_mutex.unlock()

	# Unblock by posting.
	keepalive_semaphore.post()

	keepalive_thread.wait_to_finish()


func _on_KeepAliveTimer_timeout():
	keepalive_semaphore.post()

func _notification(what):
	if what == MainLoop.NOTIFICATION_WM_QUIT_REQUEST:
		if keepalive_thread != null:
			stop_keepalive_thread()
		get_tree().quit() # default behavior


func _on_OpenFileDialog_file_selected(path):
	var error = sbgnserver.load_file(path)


func _on_HTTPRequest_request_completed(result, response_code, headers, body):
	print("response code: " + str(response_code))
	print("result: " + str(result))
	
	# check content-type of response, if not json we can dismiss
	var flagIsJson = false
	for contenttype in headers:
		if contenttype == "Content-Type: application/json":
			flagIsJson = true
			break
	
	if flagIsJson:
		var response = parse_json(body.get_string_from_utf8())
		Globals.data = response
		load_map()
		
func load_map():
	
	var nodeTestInstance = nodeTestScene.instance()
	Globals.currentViewport = mapViewContainer.get_node("Viewport")
	mapViewContainer.get_node("Viewport").add_child(nodeTestInstance)
	#Globals.currentViewport.set_process_input(true)
	nodeTestInstance.load_data(Globals.data)
	
	pass


func _on_MapView_show_add_glyph_dialog():
	var mouse_pos = get_viewport().get_mouse_position()
	var dialog_pos = mouse_pos - (addGlyphDialog.rect_min_size / 2 )
	var popup_rect = Rect2(dialog_pos, addGlyphDialog.rect_min_size)
	print("popup_rect: " + str(popup_rect))
	addGlyphDialog.popup(popup_rect)
	pass # Replace with function body.

func _on_MapView_hide_add_glyph_dialog():
	addGlyphDialog.visible = false
	pass # Replace with function body.


func _on_NewProjectFileDialog_dir_selected(dir:String):
	if Globals.is_git_working:
		Globals.current_project_dir = dir
		print("new project at: " + str(dir))
		var git_cmd = Globals.config.get_value("git", "gitPath")
		var gitI = GitInterfaceClass.new(git_cmd)
		gitI.git_init(dir)
		
		var filename = "current.vgraph"
		var file = File.new()
		file.open(dir.plus_file(filename), File.WRITE)
		file.close()
		
		gitI.add(dir, filename)
		
		gitI.status(dir)
		
		gitI.commit(dir, "init")
		
		gitI.status(dir)
		
		pass
	else:
		print("git not working, cannot create projects")
	
	pass # Replace with function body.

