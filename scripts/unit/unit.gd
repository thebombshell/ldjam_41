extends "res://scripts/unit/selectable.gd"

const DEFAULT_MAT = preload("res://materials/unit_material.tres");
const SELECTED_MAT = preload("res://materials/unit_select_material.tres");

# absolute objects

onready var nav = get_node("/root/Scene/World");

# child objects

onready var mesh = get_node("MeshInstance");

# unit vars

var order = 0;
var target = null;
var path = null;
var path_traversed = 0;
var unit_speed = 200.0;
var unit_max_health = 10.0;
var unit_health = 10.0;
var unit_damage = 1.0;
var slow_timer = 0.0;

# selectable functionality

func selectable_set_selected(is_selected):
	
	mesh.set_surface_material(0, SELECTED_MAT if is_selected else DEFAULT_MAT);
	return;

func selectable_give_order(new_order, new_target):
	
	order = new_order;
	target = null if order == ORDER_STOP else new_target;
	
	if order != ORDER_STOP:
		
		print(target);
		path = nav.get_simple_path(translation, target if order == ORDER_MOVE else target.translation);
		path_traversed = 0;
	
	return;

# path helpers

func traverse_path(delta):
	
	if path == null:
		return;
	
	if path_traversed < path.size():
		
		slow_timer -= delta;
		var dist = unit_speed * delta * (0.5 if slow_timer > 0.0 else 1.0);
		var next_position = nav.get_closest_point_to_segment(path[path_traversed] - Vector3(0.0, 0.25, 0.0), path[path_traversed] + Vector3(0.0, 0.25, 0.0));
		var direction = (next_position - translation).normalized();
		var result = move_and_slide(direction * dist, Vector3(0.0, 1.0, 0.0));
		if result.length() < dist * 0.5:
			
			slow_timer += 0.1;
			if slow_timer > 5.0:
				
				slow_timer = 0.0;
				order = ORDER_STOP;
				path = null;
		if translation.distance_squared_to(next_position) < 0.01:
			
			path_traversed += 1;
		
	else:
		
		if order == ORDER_MOVE:
			
			order = ORDER_STOP;
		path = null;
	
	return;

# processes

func process_order_move(delta):
	
	traverse_path(delta);
	return;

func process_order_interact(delta):
	
	traverse_path(delta);
	return;

func process_order_attack(delta):
	
	traverse_path(delta);
	return;

func process_orders(delta):
	
	if order == ORDER_MOVE:
		
		process_order_move(delta);
	elif order == ORDER_INTERACT:
		
		process_order_interact(delta);
	elif order == ORDER_ATTACK:
		
		process_order_attack(delta);
	
	return;

func _ready():
	
	return;

func _process(delta):
	
	process_orders(delta);
	
	return;
