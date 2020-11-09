extends Object

func _init():
	ConfigurationEvents.connect("sbgn_backend_path_changed", self, "_on_sbgn_backend_changed")

func _on_sbgn_backend_changed(path:String):
	
	if not path.ends_with(".jar"):
		ConfigurationEvents.emit_signal("sbgn_backend_not_working", \
			"Provided file must be the jar of the sbgn mini rest server")
		return
	
	var output = []
	var pathToJava = Globals.config.get_value("libSBGN", "javaPath")
	var exit_code = OS.execute(pathToJava, ["-jar", path, "-v"], true, output, true)
	# looking for: minirestsbgn version 0.1
	
	if exit_code != 0:
		ConfigurationEvents.emit_signal("sbgn_backend_not_working", \
			"Provided REST SBGN jar doesn't work, returned exit code: "+str(exit_code))
		return
	
	var line:String = output[0]
	if not line.begins_with("minirestsbgn version "):
		ConfigurationEvents.emit_signal("sbgn_backend_not_working", \
			"SBGN backend produced an unexpected version string, should be: minirestsbgn version <version_number>")
		return
	
	var version_string = line.lstrip("minirestsbgn version ")
	ConfigurationEvents.emit_signal("sbgn_backend_successfully_tested")
