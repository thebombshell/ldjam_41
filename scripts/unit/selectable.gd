extends KinematicBody

# orders

const ORDER_STOP = 0;
const ORDER_MOVE = 1;
const ORDER_INTERACT = 2;
const ORDER_ATTACK = 3;

# absolute objects

onready var controller = get_node("/root/Scene/World/Controller");

# essential functionality

func selectable_set_selected(is_selected):
	
	print("SELECTED: " + is_selected);
	return;

func selectable_give_order(order_index, order_target):
	
	return;

func selectable_get_action_names():
	
	var output = ["Destroy"];
	
	return output;

func selectable_on_action(action_name):
	
	if action_name == "Destroy":
		call_deferred("selectable_destroy");
	
	return;

func selectable_destroy():
	
	var index = controller.selected_bodies.find_last(self);
	if index >= 0:
		
		controller.selected_bodies.remove(index);
	else:
		
		print("COULD NOT FIND SELECTED_BODIES INDEX");
	index = controller.selectables.find_last(self);
	if index >= 0:
		
		controller.selectables.remove(index);
	else:
		
		print("COULD NOT FIND SELECTABLES INDEX");
	queue_free();
	return;

# helpers

func selectable_stop_order(order_target):
	
	selectable_give_order(ORDER_STOP, null);
	return;

func selectable_move_order(order_target):
	
	selectable_give_order(ORDER_MOVE, order_target);
	return;

func selectable_interact_order(order_target):
	
	selectable_give_order(ORDER_INTERACT, order_target);
	return;

func selectable_attack_order(order_target):
	
	selectable_give_order(ORDER_ATTACK, order_target);
	return;

func _ready():
	
	controller.selectables.append(self);
	return;