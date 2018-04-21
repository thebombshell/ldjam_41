extends PhysicsBody

const ORDER_STOP = 0;
const ORDER_MOVE = 1;
const ORDER_INTERACT = 2;
const ORDER_ATTACK = 3;

const DEFAULT_MAT = preload("res://materials/unit_material.tres");
const SELECTED_MAT = preload("res://materials/unit_select_material.tres");

# absolute objects

onready var nav = get_node("/root/Scene/World");

# child objects

onready var mesh = get_node("MeshInstance");

# orders and pathing vars

var order = 0;
var target = null;
var path = null;
var path_traversed = 0;

# unit stats vars

var unit_speed = 5.0;

# unit functionality

func unit_set_selected(is_selected):
	
	print(is_selected);
	mesh.set_surface_material(0, SELECTED_MAT if is_selected else DEFAULT_MAT);
	return;

func unit_give_order(new_order, new_target):
	
	order = new_order;
	target = null if order == ORDER_STOP else new_target;
	
	if order != ORDER_STOP:
		
		print(target);
		path = nav.get_simple_path(translation, target if order == ORDER_MOVE else target.translation);
		path_traversed = 0;
	
	return;

# path helpers

func traverse_path(delta):
	
	if path_traversed < path.size():
		
		var len_traversed = 0.0;
		var traversed_speed = delta * unit_speed;
		while len_traversed < traversed_speed && path_traversed < path.size():
			var next_position = nav.get_closest_point(path[path_traversed]);
			var distance = next_position - translation;
			var direction = distance.normalized();
			distance = min(traversed_speed, distance.length());
			translation += direction * distance;
			len_traversed += distance;
			if translation.distance_squared_to(next_position) < 0.01:
				
				path_traversed += 1;
		
	else:
		
		print("journey complete");
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
