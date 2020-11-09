extends Popup


export(String) var type:String = "radial"
export(int) var radial_subdivision1 = 3
export(int) var radial_subdivision2 = 3

#######
# Dummy texture button is there to prevent First radial button to start hovered
# which happens everytime the dialog is shown
#######

# works
#func _gui_input(event):
#	print("base dialog "+str(event.as_text()))

var center:Vector2 = Vector2(150,150)
var mouse_limit_radius:int = 65 # in pixels

#func _process(_delta):
#
#	if visible:
#		var mouse_pos = get_local_mouse_position()
#		#print(mouse_pos)
#
#		if mouse_pos.distance_to(center) > 80:
#			var last_point_direction = center.direction_to(mouse_pos) * 80
#			#print(last_point_direction)
#			warp_mouse(center + last_point_direction)
#
#
#		pass

func _unhandled_input(event):
	
	if visible and event is InputEventMouseMotion:
		var mouse_pos = get_local_mouse_position()
#		print(mouse_pos)
#		print(event.relative)
#		print(event.speed)
		
		#var predicted_pos:Vector2 = mouse_pos + event.speed
		
		if mouse_pos.distance_to(center) > mouse_limit_radius:# or predicted_pos.distance_to(center) > 80:
			var last_point_direction = center.direction_to(mouse_pos) * mouse_limit_radius
			warp_mouse(center + last_point_direction)

			pass
#		if predicted_pos.distance_to(center) > 80:
#			print("Predicition too far")
#			var last_point_direction = center.direction_to(predicted_pos) * 80
#			warp_mouse(center + last_point_direction)
		
		pass
	
	pass
