extends Object

var git_cmd

func _init(path):
	git_cmd = path

# init a directory
func git_init(dir):
	var output = []
	var exit_code = OS.execute(git_cmd, ["init", dir], true, output, true)
	_send_log_msg_with_header(output, "git init")

func status(dir):
	var output = []
	var exit_code = OS.execute(git_cmd, ["-C", dir, "status"], true, output, true)
	_send_log_msg_with_header(output, "git status")

func add(dir, filename):
	var output = []
	var exit_code = OS.execute(git_cmd, ["-C", dir, "add", filename], true, output, true)
	_send_log_msg_with_header(output, "git add")

func commit(dir, msg):
	var output = []
	var exit_code = OS.execute(git_cmd, ["-C", dir, "commit", "-m", msg], true, output, true)
	_send_log_msg_with_header(output, "git commit")

func _array_to_multiline_string(string_array:Array)-> String:
	var concat := ""
	for potential_multiline in string_array:
		for line in potential_multiline.split("\n"):
			if line.empty(): continue
			concat += line.strip_edges(true, true) + "\n"
	concat = concat.strip_edges(false, true)
	return concat

func _send_log_msg_with_header(string_array:Array, header:String)-> void:
	var string_output = _array_to_multiline_string(string_array)
	string_output = header + ": " + string_output
	GlobalEvents.emit_signal("log_msg", string_output)
