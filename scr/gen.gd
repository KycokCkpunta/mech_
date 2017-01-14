extends Node2D
const EPS = 0.1
var count = 32
var points = [Vector2(0,0)]
var prop_points = [] #pos, size (small,big,none),is_key (true,false,end,start)


func gen():
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
		
	var st_point = key_points[randi()%key_points.size()]
	prop_points.append([st_point,"big","start"])
	var end_point 
	var dist = 0
	for i in key_points:
		if i.distance_to(st_point) > dist:
			dist = i.distance_to(st_point)
			end_point = i
	prop_points.append([end_point,"big","end"])
	
	
	
 
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