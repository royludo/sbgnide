extends Label

func _ready():
	ConfigurationEvents.connect("git_not_working", self, "_on_git_not_working")
	ConfigurationEvents.connect("git_successfully_tested", self, "_on_git_successfully_tested")

func _on_git_not_working(msg):
	text = "git: off"
	hint_tooltip = msg

func _on_git_successfully_tested():
	text = "git: OK"

