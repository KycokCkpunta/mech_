extends TileMap

var prop_points
var points

var is_opt = false

func fill_rooms():
	for room in get_children():
		var light = load("res://scn/room_props/roof_light.tscn").instance()
		room.add_child(light)

func optimize():
	if not is_opt:
		for room in get_children():
			for ch in room.get_children():
				if ch.has_method("off"):
					ch.off()
		is_opt = true
func deoptimize():
	if is_opt:
		for room in get_children():
			for ch in room.get_children():
				if ch.has_method("on"):
					ch.on()
		is_opt = false
	

func _ready():
	get_node("../gen").gen()
	prop_points = get_node("../gen").prop_points
	points = get_node("../gen").points
	
	#makingrooms
	var id = 0
	for i in prop_points:
		var size
		var pos
		var color
		if i[1] == "none":
			continue
		if i[1] == "small":
			size = Vector2(8,8)
			pos=i[0]*16
			
		if i[1] == "big":
			size = Vector2(12,12)
			pos=i[0]*16
		
		if (i[2] in ["start","end"]) != true:
			var box = load("res://scn/box.tscn").instance()
			box.room = i[1]+"_"+str(id)
			box.set_pos(map_to_world(pos))
			box.size = map_to_world(size)/2
			add_child(box)
			
		for x in range(pos.x-size.x/2,pos.x+size.x/2):
			for y in range(pos.y-size.y/2,pos.y+size.y/2):
				set_cell(x,y,0,randi()%2,randi()%2,randi()%2)
		id+=1
	#making tunnels
	for i in points.keys():
		var start_pos = i*16
		var end_pos = points[i]*16
		for j in range(16):
			var perc = float(j)
			var pos = start_pos.linear_interpolate(end_pos,perc/16).snapped(Vector2(1,1))
			if start_pos.x == end_pos.x:
				for x in range(pos.x-1,pos.x+1):
					set_cell(x,pos.y,0,randi()%2,randi()%2,randi()%2)
			if start_pos.y == end_pos.y:
				for y in range(pos.y-1,pos.y+1):
					set_cell(pos.x,y,0)
	
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