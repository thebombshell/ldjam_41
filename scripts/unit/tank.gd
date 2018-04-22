extends "res://scripts/unit/unit.gd"

const Nest = preload("res://scripts/unit/enemy_nest.gd");

onready var audio = get_node("AudioStreamPlayer");


func selectable_get_action_names():
	
	var output = ["Destroy", "Siege"];
	
	return output;

func selectable_on_action(action_name):
	
	if action_name == "Destroy":
		
		call_deferred("selectable_destroy");
		return true;
	elif action_name == "Siege":
		
		var can_siege = true;
		var siege = null;
		for body in area.get_overlapping_bodies():
			
			if body.has_method("on_enemy_damage"):
				
				can_siege = false;
				break;
			if body is Nest && !body.is_queued_for_deletion():
				
				siege = body;
		
		if siege != null && can_siege:
			
			siege.queue_free();
			var is_win = true;
			for node in nav.get_children():
				
				if node is Nest && !node.is_queued_for_deletion():
					
					is_win = false;
					break;
			
			if is_win:
				
				get_tree().change_scene("res://scenes/win_scene.tscn");
			
			on_unit_damage(250.0);
			return true;
	
	return false;

func _ready():
	
	unit_speed = 100.0;
	unit_max_health = 500.0;
	unit_health = 500.0;
	unit_range = 5.0;
	unit_damage = 20.0;
	return;