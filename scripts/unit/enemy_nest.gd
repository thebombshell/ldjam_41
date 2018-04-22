extends KinematicBody

const Offenders = [
	preload("res://objects/units/enemy_unit.tscn"),
	preload("res://objects/units/enemy_unit.tscn"),
	preload("res://objects/units/enemy_unit.tscn")];

const Defenders = [
	preload("res://objects/units/enemy_unit.tscn"),
	preload("res://objects/units/enemy_unit.tscn"),
	preload("res://objects/units/enemy_unit.tscn")];

onready var world = get_node("/root/Scene/World");
onready var base = get_node("/root/Scene/World/Base");

var spawn_timer = 10.0;
var spawned_objects = Array();

func spawn_offender():
	
	var spawn = Offenders[randi()%3].instance();
	var angle = rand_range(0.0, 360.0);
	spawn.translation = translation + Vector3(cos(angle), 0.0, sin(angle)) * 1.5;
	spawn.move_order(base.translation + Vector3(0.0, 1.0, 0.0))
	world.add_child(spawn);
	
	return;

func spawn_defender():
	
	var spawn = Defenders[randi()%3].instance();
	spawned_objects.append(weakref(spawn));
	var angle = rand_range(0.0, 360.0);
	var offset = Vector3(cos(angle), 0.0, sin(angle));
	spawn.translation = translation + offset * 1.5;
	spawn.move_order(translation + offset * 3.0  + Vector3(0.0, 1.0, 0.0));
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
			
			spawn_offender();
		else:
			
			spawn_offender();
		spawn_timer = 20.0;
		
	return;