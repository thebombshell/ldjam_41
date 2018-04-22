extends "res://scripts/unit/unit.gd"

const Unit = preload("res://scripts/unit/unit.gd");

func selectable_get_action_names():
	
	var output = ["Destroy", "Heal"];
	
	return output;

func selectable_on_action(action_name):
	
	if action_name == "Destroy":
		
		call_deferred("selectable_destroy");
	elif action_name == "Heal":
		
		var heal = null;
		for body in area.get_overlapping_bodies():
			
			if body != self && body is Unit:
				
				if (heal == null && body.unit_health < body.unit_max_health) \
					|| (heal != null && (body.unit_max_health - body.unit_health) > (heal.unit_max_health - heal.unit_health)):
					
					heal = body;
		
		if heal != null:
			
			heal.on_unit_damage(-50.0);
			on_unit_damage(10.0);
	
	return;

func _ready():
	
	unit_speed = 200.0;
	unit_max_health = 20.0;
	unit_health = 20.0;
	unit_range = 2.0;
	unit_damage = 10.0;
	return;