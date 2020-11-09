extends Label

func _ready():
	ConfigurationEvents.connect("sbgn_backend_not_working", self, "_on_sbgn_backend_not_working")
	ConfigurationEvents.connect("sbgn_backend_successfully_tested", self, "_on_sbgn_backend_successfully_tested")

func _on_sbgn_backend_not_working(msg):
	text = "SBGN server: off"
	hint_tooltip = msg

func _on_sbgn_backend_successfully_tested():
	text = "SBGN server: configured"

