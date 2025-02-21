extends Node

var current_waypoint: VentWaypoint = null

func set_current_waypoint(waypoint: VentWaypoint):
	var new_waypoint = waypoint
	current_waypoint = new_waypoint

func move_left():
	set_current_waypoint(current_waypoint.way_left)
	
func move_right():
	set_current_waypoint(current_waypoint.way_right)
	
func move_up():
	set_current_waypoint(current_waypoint.way_up)
	
func move_down():
	set_current_waypoint(current_waypoint.way_down)
	
