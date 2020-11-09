extends Object

func _init():
	ConfigurationEvents.connect("git_path_changed", self, "_on_git_changed")

func _on_git_changed(path:String):
	
	if not path.ends_with("git.exe"):
		ConfigurationEvents.emit_signal("git_not_working", \
			"Provided file must be git.exe")
		return
	
	var output = []
	var exit_code = OS.execute(path, ["--version"], true, output, true)
	# looking for: git version 2.25.1.windows.1
	
	if exit_code != 0:
		ConfigurationEvents.emit_signal("git_not_working", \
			"Provided git executable doesn't work, returned exit code: "+str(exit_code))
		return
	
	var line:String = output[0]
	if not line.begins_with("git version "):
		ConfigurationEvents.emit_signal("git_not_working", \
			"Git produced an unexpected version string, should be: git version <version_number>")
		return
	
	var version_string:String = line.lstrip("git version ")
	
	ConfigurationEvents.emit_signal("git_successfully_tested")

