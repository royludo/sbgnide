extends Line2D

var total_length = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


func create_edge(item):
	
	var start = Vector2(item.start.x, item.start.y)
	var end = Vector2(item.end.x, item.end.y)
	#draw_line(start, end, Color.blue)
	#var line2D = Line2D.new()
	self.width = 1.0
	self.default_color = Color(0.1, 0.1, 0.1, 1)
	self.antialiased = true
	self.add_point(start)
	
	var rect1 = ColorRect.new()
	rect1.rect_position = start
	rect1.rect_position.y -= 5
	rect1.rect_pivot_offset.y += 5
	
	var previous_point = start
	var previous_rect = rect1
	var rects = []
	for nextpointitem in item.next:
		var nextpoint = Vector2(nextpointitem.x, nextpointitem.y)
		self.add_point(nextpoint)
		
		# rest is for colorrect
		var dst = previous_point.distance_to(nextpoint)
		total_length += dst
		var angle = previous_point.angle_to_point(nextpoint) + PI
		previous_rect.rect_size = Vector2(dst, 10)
		previous_rect.set_rotation(angle) # rect_rotation ? 
		rects.append(previous_rect)
		
		var next_rect = ColorRect.new()
		next_rect.rect_position = nextpoint
		next_rect.rect_position.y -= 5
		next_rect.rect_pivot_offset.y += 5
		
		previous_rect = next_rect
		previous_point = nextpoint
		
	
	self.add_point(end)

	# compute last colorrect
	var dst = previous_point.distance_to(end)
	total_length += dst
	var angle = previous_point.angle_to_point(end) + PI
	previous_rect.rect_size = Vector2(dst, 10)
	previous_rect.set_rotation(angle) # rect_rotation ? 
	rects.append(previous_rect)

	# use colorrect as reference to create correct visiblityNotifier2D
	for rect in rects:
		## show color rect for debug ##
#		rect.color = Color(0,0,rand_range(0,1),0.4)
#		line2D.add_child(rect)
		var visNotif = VisibilityNotifier2D.new()
		visNotif.rect = Rect2(rect.rect_position, rect.rect_size)
		#visNotif.connect("viewport_entered", self, "_viznotify_line_viewportentered", [line2D])
		#visNotif.connect("viewport_exited", self, "_viznotify_line_viewportexited", [line2D])
		self.add_child(visNotif)
	
	#self.visible = false

