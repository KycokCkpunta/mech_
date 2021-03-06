extends Node2D
const EPS = 0.1
var count = 64
var points = [Vector2(0,0)]
var prop_points = [] #pos, size (small,big,none),is_key (true,false,end,start)

func corners(arr):
	var x_l = 0
	var y_t = 0
	var x_r = 0
	var y_b = 0
	for i in arr:
		if i.x < x_l:
			x_l = i.x
		if i.x > x_r:
			x_r = i.x
		if i.y < y_b:
			y_b = i.y
		if i.y > y_t:
			y_t = i.y
	return [x_l-4,x_r+4,y_b-4,y_t+4]

func gen():
	var perlin = get_node("../perlin")
	randomize()
	var i = 1
	points = [Vector2(0,0)]
	while i != count:
		var j = randi()%points.size()
		var sides = [0,1,2,3] #l,r,t,b
		for q in points:
			if points[j] == q-Vector2(1,0):
				sides[1]=null
			if points[j] == q+Vector2(1,0):
				sides[0]=null
			if points[j] == q-Vector2(0,1):
				sides[2]=null
			if points[j] == q+Vector2(0,1):
				sides[3]=null
		var can = false
		for el in sides:
			if el != null:
				can = true
		if can:
			var dir = randi()%4
			if sides[dir] == 0:
				points.append(points[j]-Vector2(1,0))
				i+=1
			if sides[dir] == 1:
				points.append(points[j]+Vector2(1,0))
				i+=1
			if sides[dir] == 2:
				points.append(points[j]+Vector2(0,1))
				i+=1
			if sides[dir] == 3:
				points.append(points[j]-Vector2(0,1))
				i+=1
	var corners = corners(points)
	var a = perlin.perlin(corners[1]-corners[0],corners[3]-corners[2],1)[0]
	points = get_dots_with_neighbor(points)
	var key_points = []
	prop_points = [] #pos, size (small,big,none),is_key (true,false,end,start)
	for i in points.keys():
		if points.values().count(i) < 2:
			if points.values().count(i) < 1 and randi()%2 == 1:
				prop_points.append([i,"small","false"])
			else:
				prop_points.append([i,"big","false"])
		elif randi()%2 == 1:
			prop_points.append([i,"big","true"])
			key_points.append(i)
		else:
			if key_points.size() < 3:
				prop_points.append([i,"big","true"])
				key_points.append(i)
			else:
				prop_points.append([i,"none","false"])
	
	var st_point_id = key_points[randi()%key_points.size()]
	var st_point = prop_points[prop_points.find([st_point_id,"big","true"])]
	prop_points[prop_points.find([st_point_id,"big","true"])] = [st_point[0],st_point[1],"start"]
	var end_point_id
	var dist = 0
	for i in key_points:
		if i.distance_to(st_point[0]) > dist:
			dist = i.distance_to(st_point[0])
			end_point_id = prop_points.find([i,"big","true"])
	var end_point = prop_points[end_point_id]
	prop_points[end_point_id] = [end_point[0],end_point[1],"end"]
	
	var a = perlin.perlin(corners[1]-corners[0],corners[3]-corners[2],0.3)[0]
	for x in range(corners[0],corners[1]):
		for y in range(corners[2],corners[3]):
			for i in range(prop_points.size()):
				var pos = prop_points[i][0]
				var iter_pos = Vector2(x,y)
				if pos == iter_pos:
					prop_points[i].append(a[x][y])
	
	
 
func get_dots_with_neighbor(dots):
	var dots_with_neighbor = {}
	for dot in dots:
		var next_dot = get_neighbor(dot, dots_with_neighbor)
		dots_with_neighbor[dot] = next_dot
	return dots_with_neighbor
 
func get_neighbor(start_dot, dots_with_neighbor):
	var dmin = 9999
	var mdot = start_dot
	for dot in dots_with_neighbor.keys() + dots_with_neighbor.values():
		var d = start_dot.distance_to(dot)
		if d != 0 and dmin > d - EPS:
			if dots_with_neighbor[dot] != start_dot:
				if check_intersection(start_dot, dot, dots_with_neighbor)==false:
					dmin = d
					mdot = dot
	return mdot
 
func check_intersection(start_dot, dot, dots_with_neighbor):
	for k in dots_with_neighbor.keys():
		if intersection(k, dots_with_neighbor[k], start_dot, dot):
			return true
	return false
 
func intersection(veca_1, veca_2, vecb_1, vecb_2):
	var v1 = (vecb_2.x - vecb_1.x) * (veca_1.y - vecb_1.y) - (vecb_2.y - vecb_1.y) * (veca_1.x - vecb_1.x)
	var v2 = (vecb_2.x - vecb_1.x) * (veca_2.y - vecb_1.y) - (vecb_2.y - vecb_1.y) * (veca_2.x - vecb_1.x)
	var v3 = (veca_2.x - veca_1.x) * (vecb_1.y - veca_1.y) - (veca_2.y - veca_1.y) * (vecb_1.x - veca_1.x)
	var v4 = (veca_2.x - veca_1.x) * (vecb_2.y - veca_1.y) - (veca_2.y - veca_1.y) * (vecb_2.x - veca_1.x)
	return (v1 * v2 < 0) and (v3 * v4 < 0)