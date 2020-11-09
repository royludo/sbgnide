extends Camera2D


var dragging_camera:bool = false
var drag_start_pos:Vector2
var camera_start_pos:Vector2
var zoom_strength:float = 0.1

signal zoom_changed(zoom)

func _unhandled_input(event):
	if event.is_action_pressed("camera_drag"):
		dragging_camera = true
		drag_start_pos = get_viewport().get_mouse_position()
		camera_start_pos = get_position()
		#print(str(drag_start_pos))
	elif event.is_action_released("camera_drag"):
		dragging_camera = false
	
	if event.is_action_pressed("zoom_in"):
		zoom *= (1 - zoom_strength)
		emit_signal("zoom_changed", zoom.x)
	elif event.is_action_pressed("zoom_out"):
		zoom *= (1 + zoom_strength)
		emit_signal("zoom_changed", zoom.x)


func _process(_delta):
	if dragging_camera:
		var current_mouse_pos = get_viewport().get_mouse_position()
		var movement = current_mouse_pos - drag_start_pos
		#print(str(camera_start_pos)+" "+str(movement))
		if movement.x != 0 or movement.y != 0:
			set_position(camera_start_pos - (movement * zoom.x))
		#print("offset "+str(camera.position))
