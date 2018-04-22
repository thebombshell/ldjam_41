extends KinematicBody

const Enemy = preload("res://objects/units/enemy_unit.tscn");

onready var world = get_node("/root/Scene/World");

var spawn_timer = 20.0;
var spawned_objects = Array();

func spawn_object():
	
	var spawn = Enemy.instance();
	spawned_objects.append(weakref(spawn));
	var angle = rand_range(0.0, 360.0);
	spawn.translation = translation + Vector3(cos(angle), 0.0, sin(angle)) * 1.5;
	world.add_child(spawn);
	
	return;

func _process(delta):
	
	spawn_timer -= delta;
	if spawn_timer < 0.0:
		var dead_objects = Array();
		for spawn in spawned_objects:
			
			if !spawn.get_ref():
				
				dead_objects.append(spawn);
		for dead in dead_objects:
			
			spawned_objects.remove(spawned_objects.find_last(dead));
		
		if spawned_objects.size() < 3:
			
			spawn_object();
		spawn_timer = 20.0;
		
	return;