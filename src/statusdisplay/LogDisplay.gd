extends Control

# keep history of log messages
# displays the last one
# history accessible through scrollable popup
# formatting for warning and errors

export(StyleBoxFlat) var warning_style:StyleBoxFlat
export(StyleBoxFlat) var error_style:StyleBoxFlat
export(StyleBoxFlat) var info_style:StyleBoxFlat
export(int) var popup_margin:int

# array of pairs {MSG_TYPE, String}
var msg_stack:Array = []

enum MSG_TYPE {INFO, WARNING, ERROR}

onready var popup_vbox := $PopupPanel/ScrollContainer/VBoxContainer

func _create_msg_type_pair(type:int, msg:String)-> Dictionary:
	return {"type": type, "message": msg}

func add_msg(msg:String)-> void:
	var msg_dict = _create_msg_type_pair(MSG_TYPE.INFO, msg)
	_update_logdisplay_with_msg(msg_dict)

func add_warning(msg:String)-> void:
	var msg_dict = _create_msg_type_pair(MSG_TYPE.WARNING, msg)
	_update_logdisplay_with_msg(msg_dict)

func add_error(msg:String)-> void:
	var msg_dict = _create_msg_type_pair(MSG_TYPE.ERROR, msg)
	_update_logdisplay_with_msg(msg_dict)

func get_last_message()-> Dictionary:
	if msg_stack.empty():
		return {}
	return msg_stack.back()

func _update_label():
	var last_msg := get_last_message()
	if not last_msg.empty():
		$Label.text = last_msg.message
		
		match last_msg.type:
			MSG_TYPE.WARNING:
				$Label.set('custom_styles/normal', warning_style)
			MSG_TYPE.ERROR:
				$Label.set('custom_styles/normal', error_style)


func _on_Label_gui_input(event:InputEvent):
	#print("in label gui input" + str(event))
	if event.is_action_pressed("mouse_select"):
		#print("logdisplay pressed " + str($Label.rect_size))
		$PopupPanel.popup(_get_popup_rect())


func _get_popup_rect()-> Rect2:	
	var popup_width = $Label.rect_size.x
	var popup_height = 200
	var popup_size = Vector2(popup_width, popup_height)
	
	var label_pos = $Label.rect_global_position
	var popup_pos = Vector2(label_pos.x, label_pos.y - popup_margin - popup_height)
	
	return Rect2(popup_pos, popup_size)


func _add_message_to_popup(msg:Dictionary)-> void:
	var msg_item = Label.new()
	msg_item.text = msg.message
	match msg.type:
			MSG_TYPE.INFO:
				msg_item.set('custom_styles/normal', info_style)
			MSG_TYPE.WARNING:
				msg_item.set('custom_styles/normal', warning_style)
			MSG_TYPE.ERROR:
				msg_item.set('custom_styles/normal', error_style)
	popup_vbox.add_child(msg_item)


func _update_logdisplay_with_msg(msg_dict:Dictionary)-> void:
	msg_stack.push_back(msg_dict)
	_update_label()
	_add_message_to_popup(msg_dict)
