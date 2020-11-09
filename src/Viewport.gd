extends Viewport

# necessary hack to pass event down correctly
func _input(event):
	#print("in viewport _unhandled_input " + str(event))
	unhandled_input(event)
	#input(event)
	#$NodeTest._unhandled_input(event)
	
#	for c in get_children():
#		c.input(event)

#func _unhandled_input(event):
#	print("in viewport unhandled_input " + str(event))
