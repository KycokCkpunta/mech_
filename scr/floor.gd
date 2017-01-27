extends TileMap

onready var astar = AStar.new()
onready var perlin = get_node("../perlin")
var path = []

var prop_points
var points

var room_sizes = [Vector2(4,4),Vector2(8,8),Vector2(12,12)] #none, small, big

#buff_vars
var isAllMap = false
var isAllRooms = false
var isPath = false
var all_doors = true


var is_opt = false

func get_start_pos():
	var pos = Vector2(0,0)
	for room in get_children():
		if room.get_name().find("root_box") != -1:
			if room.isStart:
				pos = room.get_pos()
	return(pos)

func get_end_pos():
	var pos = Vector2(0,0)
	for room in get_children():
		if room.get_name().find("root_box") != -1:
			if not room.isStart:
				pos = room.get_pos()
	return pos

func open_map():
	for room in get_children():
		if isAllMap:
			room.get_node("map_expl").show()
		else:
			pass
		if room.get_name().find("tunnel") == -1:
			if isAllRooms:
				room.get_node("map_expl").show()
			else:
				pass
		if isPath:
			for i in path:
				if room.get_pos() == i*256:
					room.get_node("map_expl").show()
		else:
			pass

func fill_rooms():
	for room in get_children():
		if room.get_name().find("tunnel") == -1:
			#basic_lights (testing)
			var light = load("res://scn/room_props/roof_light.tscn").instance()
			room.add_child(light)
			pass
		if room.get_name().find("tunnel") != -1:
			#door
			for c in range(2):
				if randi()%2 == 0 or all_doors:
					var door = load("res://scn/room_props/door.tscn").instance()
					door.set_name("door_"+str(c))
					room.add_child(door)
			pass
	open_map()

func optimize():
	if not is_opt:
		for room in get_children():
			for ch in room.get_children():
				if ch.get_name() == "map_expl":
					ch.get_node("a").play("in")
				if ch.has_method("off"):
					ch.off()
		is_opt = true
func deoptimize():
	if is_opt:
		for room in get_children():
			for ch in room.get_children():
				if ch.get_name() == "map_expl":
					ch.get_node("a").play("out")
			if room.isIn:
				room._manage_lights()
		is_opt = false
	

func _ready():
	get_node("../gen").gen()
	prop_points = get_node("../gen").prop_points
	points = get_node("../gen").points
	
	
	
	#making rooms
	var id = 0
	var small_rooms = []
	var big_rooms = []
	var none_rooms = []
	var id_points = [] # id,pos
	var st_id = 0
	var end_id = 0
	for i in prop_points:
		var size
		var pos
		var color
		astar.add_point(id,Vector3(i[0].x,0,i[0].y))
		id_points.append([id,i[0]])
		if i[1] == "none":
			size = room_sizes[0]
			pos=map_to_world(i[0])
			none_rooms.append(pos)
			
		if i[1] == "small":
			size = room_sizes[1]
			pos=map_to_world(i[0])
			small_rooms.append(pos)
			
		if i[1] == "big":
			size = room_sizes[2]
			pos=map_to_world(i[0])
			big_rooms.append(pos)
		
		var box = load("res://scn/box.tscn").instance()
		box.room = i[1]+"_"+str(id)
		if (i[2] in ["start","end"]) == true:
			box.room = "root_box_"+str(id)
			if i[2] == "start":
				st_id = id
				box.isStart = true
			end_id = id
			box.get_node("map_expl").show()
		box.set_pos(map_to_world(pos))
		box.size = map_to_world(size)/2
		add_child(box)
			
		for x in range(pos.x-size.x/2,pos.x+size.x/2):
			for y in range(pos.y-size.y/2,pos.y+size.y/2):
				set_cell(x,y,0,randi()%2,randi()%2,randi()%2)
		id+=1
	#making tunnels
	var id = 0
	for i in points.keys():
		var from_id = 0
		var to_id = 0
		for p in id_points:
			if p[1] == i:
				from_id = p[0]
		for p in id_points:
			if p[1] == points[i]:
				to_id = p[0]
		
		if from_id == to_id:
			continue
		
		var start_pos = map_to_world(i)
		var end_pos = map_to_world(points[i])
		
		#tunnel_rooms
		var start_room = ""
		var end_room = ""
		
		#connected rooms
		for room in get_children():
			if room.get_pos() == i*256:
				start_room = room.get_name()
				for connected_room in get_children():
					if connected_room.get_pos() == points[i]*256:
						print(connected_room.get_pos(),", ",connected_room.get_name())
						room.connected_rooms.append(connected_room.get_name())
				room.connected_rooms.append("tunnel_"+str(id))
			if room.get_pos() == points[i]*256:
				end_room = room.get_name()
				for connected_room in get_children():
					if connected_room.get_pos() == i*256:
						room.connected_rooms.append(connected_room.get_name())
				room.connected_rooms.append("tunnel_"+str(id))
			
		
		
		astar.connect_points(from_id,to_id)
		
		for j in range(16):
			var perc = float(j)
			var pos = start_pos.linear_interpolate(end_pos,perc/16).snapped(Vector2(1,1))
			if start_pos.x == end_pos.x:
				for x in range(pos.x-1,pos.x+1):
					set_cell(x,pos.y,0,randi()%2,randi()%2,randi()%2)
			if start_pos.y == end_pos.y:
				for y in range(pos.y-1,pos.y+1):
					set_cell(pos.x,y,0)
		
		if small_rooms.find(start_pos) != -1:
			if start_pos.x > end_pos.x:
				start_pos-=Vector2(room_sizes[1].x/2,0)
			if start_pos.x < end_pos.x:
				start_pos+=Vector2(room_sizes[1].x/2,0)
			if start_pos.y > end_pos.y:
				start_pos-=Vector2(0,room_sizes[1].y/2)
			if start_pos.y < end_pos.y:
				start_pos+=Vector2(0,room_sizes[1].y/2)
		elif big_rooms.find(start_pos) != -1:
			if start_pos.x > end_pos.x:
				start_pos-=Vector2(room_sizes[2].x/2,0)
			if start_pos.x < end_pos.x:
				start_pos+=Vector2(room_sizes[2].x/2,0)
			if start_pos.y > end_pos.y:
				start_pos-=Vector2(0,room_sizes[2].y/2)
			if start_pos.y < end_pos.y:
				start_pos+=Vector2(0,room_sizes[2].y/2)
		elif none_rooms.find(start_pos) != -1:
			if start_pos.x > end_pos.x:
				start_pos-=Vector2(room_sizes[0].x/2,0)
			if start_pos.x < end_pos.x:
				start_pos+=Vector2(room_sizes[0].x/2,0)
			if start_pos.y > end_pos.y:
				start_pos-=Vector2(0,room_sizes[0].y/2)
			if start_pos.y < end_pos.y:
				start_pos+=Vector2(0,room_sizes[0].y/2)

		if small_rooms.find(end_pos) != -1:
			if end_pos.x > start_pos.x:
				end_pos-=Vector2(room_sizes[1].x/2,0)
			if end_pos.x < start_pos.x:
				end_pos+=Vector2(room_sizes[1].x/2,0)
			if end_pos.y > start_pos.y:
				end_pos-=Vector2(0,room_sizes[1].y/2)
			if end_pos.y < start_pos.y:
				end_pos+=Vector2(0,room_sizes[1].y/2)
		elif big_rooms.find(end_pos) != -1:
			if end_pos.x > start_pos.x:
				end_pos-=Vector2(room_sizes[2].x/2,0)
			if end_pos.x < start_pos.x:
				end_pos+=Vector2(room_sizes[2].x/2,0)
			if end_pos.y > start_pos.y:
				end_pos-=Vector2(0,room_sizes[2].y/2)
			if end_pos.y < start_pos.y:
				end_pos+=Vector2(0,room_sizes[2].y/2)
		elif none_rooms.find(end_pos) != -1:
			if end_pos.x > start_pos.x:
				end_pos-=Vector2(room_sizes[0].x/2,0)
			if end_pos.x < start_pos.x:
				end_pos+=Vector2(room_sizes[0].x/2,0)
			if end_pos.y > start_pos.y:
				end_pos-=Vector2(0,room_sizes[0].y/2)
			if end_pos.y < start_pos.y:
				end_pos+=Vector2(0,room_sizes[0].y/2)
		
		var box = load("res://scn/box.tscn").instance()
		box.room = "tunnel_"+str(id)
		if start_pos.x == end_pos.x:
			box.size = Vector2(16,(start_pos.y-end_pos.y)*8)
			box.is_horz = false
		if start_pos.y == end_pos.y:
			box.size = Vector2((start_pos.x-end_pos.x)*8,16)
			box.is_horz = true
		box.set_pos(map_to_world((start_pos+end_pos)/2))
		
		box.connected_rooms.append(start_room)
		box.connected_rooms.append(end_room)
		
		add_child(box)
		id+=1
	path = astar.get_point_path(st_id,end_id)
	var vec2_path = []
	for i in path:
		vec2_path.append(Vector2(i.x,i.z))
	path = vec2_path
	
	#making walls
	var walls = get_node("../walls")
	var cells = get_used_cells()
	var y_t = cells[0].y-5
	var y_b = cells[cells.size()-1].y+5
	cells.sort()
	var x_l = cells[0].x-5
	var x_r = cells[cells.size()-1].x+5
	for x in range(x_l,x_r):
		for y in range(y_t,y_b):
			if get_cell(x,y) == -1:
				if (get_cell(x+1,y) != -1 or
				get_cell(x-1,y) != -1 or
				get_cell(x,y+1) != -1 or
				get_cell(x,y-1) != -1):
					walls.set_cell(x,y,0)
	fill_rooms()
	var a = perlin.perlin(x_r-x_l,y_b-y_t,1)[0]
	var i = 0
	while i < x_r-x_l:
		var j = 0
		while j < y_b-y_t:
			if get_cell(i+x_l,j+y_t) != -1:
				var s = Sprite.new()
				s.set_pos(map_to_world(Vector2(i+x_l,j+y_t))+Vector2(8,8))
				s.set_texture(load("res://art/tiles/1floor.png"))
				
				s.set_modulate(Color(0,0,0))
				s.set_name(str([j,i]))
				s.set_opacity(a[j][i]*0.1)
			#	s.set_scale(Vector2(0.7,0.7))
				get_node("../gen").add_child(s)
			j+=1
		i+=1