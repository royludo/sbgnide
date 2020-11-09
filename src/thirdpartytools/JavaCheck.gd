extends Object

func _init():
	ConfigurationEvents.connect("java_path_changed", self, "_on_java_changed")

func _on_java_changed(path:String):
	
	if not path.ends_with("java.exe"):
		ConfigurationEvents.emit_signal("java_not_working", \
			"Provided file must be java.exe")
		return
	
	var output = []
	var exit_code = OS.execute(path, ["-version"], true, output, true)
	# looking for: java version "11.0.7"
	
	if exit_code != 0:
		ConfigurationEvents.emit_signal("java_not_working", \
			"Provided Java executable doesn't work, returned exit code: "+str(exit_code))
		return
	
	var line:String = output[0]
	if not line.begins_with("java version "):
		ConfigurationEvents.emit_signal("java_not_working", \
			"Java produced an unexpected version string, should be: java version \"<version_number>\"")
		return
	
	var regex = RegEx.new()
	regex.compile("\"[0-9.]+\"")
	var result = regex.search(line)
	if result:
		var quoted_version:String = result.get_string()
		var version:String = quoted_version.lstrip("\"").rstrip("\"")
		var major_version_number_string:String = version.split(".")[0]
		var major_version_number:int = int(major_version_number_string)
		
		if major_version_number < 11:
			ConfigurationEvents.emit_signal("java_not_working", \
				"Java version should be 11 or higher")
			return
		else:
			ConfigurationEvents.emit_signal("java_successfully_tested")
			return
	else:
		ConfigurationEvents.emit_signal("java_not_working", \
			"Could not parse java version number correctly")
		return
