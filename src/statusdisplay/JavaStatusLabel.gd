extends Label

# Called when the node enters the scene tree for the first time.
func _ready():
	ConfigurationEvents.connect("java_not_working", self, "_on_java_not_working")
	ConfigurationEvents.connect("java_successfully_tested", self, "_on_java_successfully_tested")

func _on_java_not_working(msg):
	text = "java: off"
	hint_tooltip = msg

func _on_java_successfully_tested():
	text = "java: OK"

