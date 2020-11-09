extends ViewportContainer

var isAddGlyphDialogShowing = false
#onready var addGlyphDialog = preload("res://AddGlyphDialog.tscn").instance()

#func _gui_input(event):
#	print("event in viewport container")

signal show_add_glyph_dialog()
signal hide_add_glyph_dialog()
	
#func _ready():
#	set_process_input(true)

func _unhandled_input(event):
	#print("in viewportcontainer unhandled " + str(event))

	
	if event.is_action_pressed("add_glyph"):
		print("add glyph")
		isAddGlyphDialogShowing = true
		emit_signal("show_add_glyph_dialog")

	
	if event.is_action_released("add_glyph"):
		print("hide addglyph dialog")
		isAddGlyphDialogShowing = false
		emit_signal("hide_add_glyph_dialog")
	
	pass

func _gui_input(event):
	#print("in viewportcontainer _gui_input " + str(event))
	$Viewport.input(event)
