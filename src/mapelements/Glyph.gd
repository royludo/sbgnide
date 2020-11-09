extends Area2D

var surface
var isSelected = false

# Called when the node enters the scene tree for the first time.
func _ready():
	var sizeVec:Vector2 = shape_owner_get_shape(0,0).extents
	surface = sizeVec.x * sizeVec.y


func create_glyph(item, ninepatchrect:NinePatchRect):
	var glyph = item
	var bbox = glyph.bbox as Dictionary
	var positionVec = Vector2(bbox.x + bbox.w/2, bbox.y + bbox.h/2)
	var sizeVec = Vector2(bbox.w, bbox.h)
	#draw_rect(Rect2(bbox.x, bbox.y, bbox.w, bbox.h), Color(1, 0, 0, 0.2))
	
	## instancing is really really slow... or not... investigate further ##
#	var glyphNode = GlyphScene.instance()
#	glyphNode.position = Vector2(bbox.x + bbox.w / 2, bbox.y + bbox.h / 2)
#	#var rect_size1 = Vector2(bbox.w, bbox.h)
#	#glyphNode.get_node("CollisionShape2D").disabled = true
#	glyphNode.shape_owner_get_shape(0,0).extents = Vector2(bbox.w, bbox.h) # <----- PROBLEM
#	#print(glyphNode.shape_owner_get_shape(0,0).extents)
#	var sprite = glyphNode.get_node("Sprite")
#	var tex_size = sprite.texture.get_size()
	#var visibility_rect = glyphNode.get_node("VisibilityNotifier2D").rect
	#visibility_rect = Rect2(glyphNode.position, rect_size)
	
	
	#var area:Area2D = Area2D.new() as Area2D
	self.position = positionVec
	#rect.rect_size = Vector2(bbox.w, bbox.h)

	var rect:RectangleShape2D = RectangleShape2D.new()
	rect.extents = sizeVec/2

	var shape_owner_id = create_shape_owner(self)
	shape_owner_add_shape(shape_owner_id, rect)

	#var sprite:Sprite = background_sprite.duplicate()
	var sprite:NinePatchRect = ninepatchrect.duplicate()
	sprite.mouse_filter = Control.MOUSE_FILTER_PASS

	var tex_size = sprite.texture.get_size()
	#print(str(rect.extents)+" "+str(sprite.texture.get_size()))
	
	var sx = sizeVec.x / tex_size.x
	var sy = sizeVec.y / tex_size.y
	
	sprite.rect_position = -sizeVec/2
	sprite.rect_size = sizeVec
	#area.scale = Vector2(sx, sy)
	sprite.visible = true
	
	add_child(sprite)
	modulate = Color(rand_range(0.2,1), rand_range(0.2,1), 0, 1)
	
	var visNotify = VisibilityNotifier2D.new()
	visNotify.rect = Rect2(-sizeVec/2, sizeVec)
	
	#visNotify.connect("viewport_entered", self, "test_viz_notify_viewportentered", [area])
	#visNotify.connect("viewport_exited", self, "test_viz_notify_viewportexited", [area])
	#set_visible(false)
	add_child(visNotify)
	
	self.input_pickable = true
	connect("input_event", self, "_on_input_event")

	#area.set_script(glyphScript)

func _on_input_event(viewport:Object, event:InputEvent, shape_idx:int):
#func _input(event):
	#if event is InputEventMouseButton && event.is_action_pressed("mouse_select"):
	if event.is_action_pressed("mouse_select"):
		print("area clicked: "+(name))
		#self.modulate.b += 0.5
		if Globals.currentMouseMode == Globals.MouseMode.SELECT:
			isSelected = true
			update()

		pass

	pass
#
#func _on_mouse_entered():
#	self.modulate.b += 0.1
#
#	pass

func _draw():
	if isSelected:
		var sizeVec = shape_owner_get_shape(0,0).extents *2
		draw_rect(Rect2(-sizeVec/2, \
		Vector2(sizeVec)), Color.yellow, false, 2)
