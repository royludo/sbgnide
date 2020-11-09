extends Node2D

onready var camera = $Camera2D
var data
onready var background_sprite = $Sprite
onready var ninepatchrect = $NinePatchRect
var threshold_area_factor = 0.00004 # 0.00002
var threshold_dist_factor = 0.02 # 0.008

#const GlyphScene = preload("res://Glyph.tscn")
const GlyphClass = preload("res://src/mapelements/Glyph.gd")
const ArcClass = preload("res://src/mapelements/Arc.gd")

var visibleNodesDict = {}
var visibleNodeOrderedPairs = []
var hiddenNodeOrderedPairs = []
var visibleLineOrderedPairs = []
var hiddenLineOrderedPairs = []

# for all map, don't care about what's on screen
var globalNodeOrderedPairs = []
var globalLineOrderedPairs = []


var node_count_threshold = 4000
var line_count_threshold = 2000
var target_draw_call = 4000

func _ready():
	#load_data(Globals.data)
	
	
#	var imagetexture = ImageTexture.new()
#	imagetexture.load("res://background.png")
#	var background_sprite = Sprite.new()
#	background_sprite.texture = imagetexture

	pass

func _draw():
	draw_line(Vector2(0, -10000), Vector2(0, 10000), Color.whitesmoke)
	draw_line(Vector2(-10000, 0), Vector2(10000, 0), Color.whitesmoke)


func load_data(data):
	self.data = data
	
	for g in data:
		var item = g as Dictionary
		if item.has("label"):
			var glyph = GlyphClass.new()
			glyph.create_glyph(item, ninepatchrect)
			add_glyph_to_map(glyph)
			
		else:
			var line2d = ArcClass.new()
			line2d.create_edge(item)
			add_child(line2d)
			
			var size_pair = [line2d.total_length, line2d]
			var index:int = globalLineOrderedPairs\
				.bsearch_custom(size_pair, self, "custom_size_compare")
			globalLineOrderedPairs.insert(index, size_pair)
			
			pass


func create_new_glyph_at(pos:Vector2) -> GlyphClass:
	var glyph = GlyphClass.new()
	glyph.create_glyph({"bbox": {"x":pos.x, "y":pos.y, "w":40, "h":20}}, ninepatchrect)
	add_glyph_to_map(glyph)
	return glyph


func add_glyph_to_map(glyph:GlyphClass):
	add_child(glyph)
			
	var size_pair = [glyph.surface, glyph]
	var index:int = globalNodeOrderedPairs\
		.bsearch_custom(size_pair, self, "custom_size_compare")
	globalNodeOrderedPairs.insert(index, size_pair)


func _on_Camera2D_zoom_changed(zoom):
	
	var draw_calls = Performance.get_monitor(Performance.RENDER_2D_DRAW_CALLS_IN_FRAME)
	var node_count = globalNodeOrderedPairs.size()
	var line_count = globalLineOrderedPairs.size()
	print("nodes: " + str(node_count) + " lines: "+str(line_count)+\
		" draw calls "+str(draw_calls) )
	
	#var fraction_node_count = ceil(node_count * 0.1)
	#var fraction_line_count = ceil(line_count * 0.1)
	
	var draw_call_diff = target_draw_call - draw_calls
	
	var fraction_node_count = ceil(1/3.0 * abs(draw_call_diff))
	var fraction_line_count = ceil(2/3.0 * abs(draw_call_diff))
	
	
	if draw_call_diff < 0: # too much to display
		print("remove " + str(fraction_node_count)+\
			" nodes and "+str(fraction_line_count)+" lines")
		
		var i = 1
		var removed_count = 0
		while removed_count < fraction_node_count and i < node_count:
			var concernedNode = globalNodeOrderedPairs[-i][1]
			if concernedNode.visible:
				concernedNode.visible = false
				removed_count += 1
			i += 1
			pass
		
		i = 1
		removed_count = 0
		while removed_count < fraction_line_count and i < line_count:
			var concernedLine = globalLineOrderedPairs[-i][1]
			if concernedLine.visible:
				concernedLine.visible = false
				removed_count += 1
			i += 1
			pass
		
		
		
		pass
	else:
		print("re-add " + str(fraction_node_count)+\
			" nodes and "+str(fraction_line_count)+" lines")
		
		var i = 0
		var added_count = 0
		while added_count < fraction_node_count and i < node_count:
			var concernedNode = globalNodeOrderedPairs[i][1]
			if not concernedNode.visible:
				concernedNode.visible = true
				added_count += 1
			i += 1
			
			pass
		
		i = 0
		added_count = 0
		while added_count < fraction_line_count and i < line_count:
			var concernedLine = globalLineOrderedPairs[i][1]
			if not concernedLine.visible:
				concernedLine.visible = true
				added_count += 1
			i += 1
			
			pass
		
		
		pass
	
	pass


func _on_Camera2D_zoom_changed_oldbackup(zoom):
	return # <------------------------------------------------------
	print("new zoom: "+str(zoom))
	var screen_size = get_viewport().size  * zoom
	var screen_area = screen_size.x * screen_size.y
	var threshold_area = threshold_area_factor * screen_area
	var threshold_dist =  threshold_dist_factor * sqrt(screen_area)
	print("area: "+str(screen_area)+" threshold: "+str(threshold_area))
	for child in get_children():
		if child is Area2D:
			var tex_size = child.get_node("Sprite").texture.get_size()
			var tex_scale = child.get_node("Sprite").scale
			var area = tex_size.x * tex_scale.x * tex_size.y * tex_scale.y
			#print("child area: "+str(area))
#			if area < threshold_area:
#				child.visible = false
#			else:
#				child.visible = true
#			pass
		elif child is Line2D:
			var size = child.points.size()
			var p1:Vector2 = child.points[0]
			var p2:Vector2 = child.points[size - 1]
			var l = p1.distance_to(p2)
			#print("distance: "+str(l))
			if l < threshold_dist:
				child.visible = false
			else:
				child.visible = true
			pass
	pass # Replace with function body.


func test_viz_notify_viewportentered(viewport, area:Area2D):
	visibleNodesDict[area.name] = area
	
	var size_pair = create_node_size_pair(area)
	
	var index1:int = visibleNodeOrderedPairs\
		.bsearch_custom(size_pair, self, "custom_size_compare")
	visibleNodeOrderedPairs.insert(index1, size_pair)
	area.visible = true
	
	
	if visibleNodeOrderedPairs.size() > node_count_threshold:
		var last_glyph_pair = visibleNodeOrderedPairs.pop_back()
		
		var index2:int = hiddenNodeOrderedPairs\
			.bsearch_custom(last_glyph_pair, self, "custom_size_compare")
		hiddenNodeOrderedPairs.insert(index2, last_glyph_pair)
		last_glyph_pair[1].visible = false
		pass
		
	
	
	pass


func test_viz_notify_viewportexited(viewport:Viewport, area:Area2D):
	visibleNodesDict.erase(area.name)
	
	var size_pair = create_node_size_pair(area)
	
	if area.visible:
		var index:int = visibleNodeOrderedPairs\
			.bsearch_custom(size_pair, self, "custom_size_compare")
		var index2:int = visibleNodeOrderedPairs.find(size_pair, index)
		
		visibleNodeOrderedPairs.remove(index2)
		
		
		# update visible nodes if room available by transferring from hidden nodes
		while visibleNodeOrderedPairs.size() <= node_count_threshold \
			and hiddenNodeOrderedPairs.size() > 0 :
			
			var first_glyph_pair = hiddenNodeOrderedPairs.pop_front()
			
			var index3:int = visibleNodeOrderedPairs\
				.bsearch_custom(first_glyph_pair, self, "custom_size_compare")
			visibleNodeOrderedPairs.insert(index3, first_glyph_pair)
			first_glyph_pair[1].visible = true
			pass
		
		
		pass
	else:
		var index:int = hiddenNodeOrderedPairs\
			.bsearch_custom(size_pair, self, "custom_size_compare")
		var index2:int = hiddenNodeOrderedPairs.find(size_pair, index)
		hiddenNodeOrderedPairs.remove(index2)
		pass
	
	area.visible = false
	
	
	pass

func _viznotify_line_viewportentered(viewport, line2D:Line2D):
	
	if line2D.visible:
#		var size_pair = create_line_size_pair(line2D)
#		print("already visible length: "+str(size_pair[0]))
		return
	
	var size_pair = create_line_size_pair(line2D)
	var index1:int = visibleLineOrderedPairs\
		.bsearch_custom(size_pair, self, "custom_size_compare")
	visibleLineOrderedPairs.insert(index1, size_pair)
	line2D.visible = true
#
#	print("entered line length: " + str(size_pair[0]))
#	print("inserte at: " + str(index1))
	
	if visibleLineOrderedPairs.size() > line_count_threshold:
		var last_line_pair = visibleLineOrderedPairs.pop_back()
		
#		print("removed line length: "+str(last_line_pair[0]))
		var index2:int = hiddenLineOrderedPairs\
			.bsearch_custom(last_line_pair, self, "custom_size_compare")
		hiddenLineOrderedPairs.insert(index2, last_line_pair)
		last_line_pair[1].visible = false
		pass
	
	pass

func _viznotify_line_viewportexited(viewport, line2D:Line2D):
	
	# if one of the segment is still on screen, don't do anything
	for child in line2D.get_children():
		if child is VisibilityNotifier2D and child.is_on_screen():
			return
			
	var size_pair = create_line_size_pair(line2D)
	
	# at this point, we know no segment of the line is on screen
	if line2D.visible: # was not hidden before
		var index:int = visibleLineOrderedPairs\
			.bsearch_custom(size_pair, self, "custom_size_compare")
		var index2:int = visibleLineOrderedPairs.find(size_pair, index)
		
#		print("line points count: " + str(line2D.points.size()))
#		print("index: " + str(index) +" index2 "+str(index2))
		visibleLineOrderedPairs.remove(index2)
		
		
		# update visible lines if room available by transferring from hidden lines
		while visibleLineOrderedPairs.size() <= line_count_threshold \
			and hiddenLineOrderedPairs.size() > 0 :
			
			var first_line_pair = hiddenLineOrderedPairs.pop_front()
			
			var index3:int = visibleLineOrderedPairs\
				.bsearch_custom(first_line_pair, self, "custom_size_compare")
			visibleLineOrderedPairs.insert(index3, first_line_pair)
			first_line_pair[1].visible = true
			pass
		
		
		pass
	else: # was already too small to be displayed
		var index:int = hiddenLineOrderedPairs\
			.bsearch_custom(size_pair, self, "custom_size_compare")
		var index2:int = hiddenLineOrderedPairs.find(size_pair, index)
		hiddenLineOrderedPairs.remove(index2)
		pass
	
	line2D.visible = false
	
	pass

#var f = 0
#var trigger = 20
#func _process(_delta):
#	f += 1
#	if f >= trigger:
#		f = 0
##		print("visible nodes count: "+str(visibleNodeOrderedPairs.size()))
##		print("hidden nodes count: "+str(hiddenNodeOrderedPairs.size()))
#		print("visible lines count: "+str(visibleLineOrderedPairs.size()))
#		print("hidden lines count: "+str(hiddenLineOrderedPairs.size()))
#	pass

# return array of 2 elements, size first then glyph
func create_node_size_pair(glyph:Area2D) -> Array:
	var result = [0,0]
	
	var sizeVec:Vector2 = glyph.shape_owner_get_shape(0,0).extents
	var size = sizeVec.x * sizeVec.y
	
	result[0] = size
	result[1] = glyph
	
	return result

func create_line_size_pair(line:Line2D) -> Array:
	var result = [0,0]
	
	var point_count = line.points.size()
	var previous_point:Vector2 = line.points[0]
	var total_length = 0
	for i in range(1,point_count):
		var length = previous_point.distance_to(line.points[i])
		total_length += length
	
	result[0] = total_length
	result[1] = line
	
	return result


static func custom_size_compare(a, b):
	if a[0] > b[0]:
		return true
	return false

func _unhandled_input(event):
	#print("in NodeMap unhandled_input" + str(event))
	if event.is_action_pressed("mouse_select"):
		match Globals.currentMouseMode:
			Globals.MouseMode.SELECT:
				pass
			Globals.MouseMode.ADD_GLYPH:
				var mouse_pos = get_viewport().get_mouse_position()
				var global_pos = get_global_mouse_position()
				print(global_pos)
				create_new_glyph_at(global_pos)

				pass
			Globals.MouseMode.ADD_ARC:
				pass
		
		pass
