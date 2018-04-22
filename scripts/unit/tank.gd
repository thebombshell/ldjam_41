extends "res://scripts/unit/unit.gd"

const Nest = preload("res://scripts/unit/enemy_nest.gd");

func selectable_get_action_names():
	
	var output = ["Destroy", "Siege"];
	
	return output;

func selectable_on_action(action_name):
	
	if action_name == "Destroy":
		
		call_deferred("selectable_destroy");
	elif action_name == "Siege":
		
		for body in area.get_overlapping_bodies():
			
			if body is Nest && !body.is_queued_for_deletion():
				
				body.queue_free();
				on_unit_damage(250.0);
				break;
	
	return;

func _ready():
	
	unit_speed = 100.0;
	unit_max_health = 500.0;
	unit_health = 500.0;
	unit_range = 5.0;
	unit_damage = 20.0;
	return;