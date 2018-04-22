extends KinematicBody

# absolute objects

onready var nav = get_node("/root/Scene/World");

# child objects

onready var area = get_node("Area");
onready var area_shape = get_node("Area/CollisionShape");
onready var health = get_node("HealthForeground");

#

var unit_speed = 200.0;
var unit_max_health = 100.0;
var unit_health = 100.0;
var unit_range = 5.0;
var unit_damage = 20.0;

var target = null;
var path = null;
var path_traversed = 0;
var slow_timer = 0.0;

func move_order(new_target):
	
	target = new_target;
	
	return;

# path helpers

func traverse_path(delta):
	
	if target != null:
		
		slow_timer = 0.0;
		path = nav.get_simple_path(translation, target);
		path_traversed = 0;
		target = null;
	
	if path == null:
		
		return;
	
	if path_traversed < path.size():
		
		slow_timer -= delta;
		
		var next_position = nav.get_closest_point_to_segment(path[path_traversed] - Vector3(0.0, 0.1, 0.0), path[path_traversed] + Vector3(0.0, 0.1, 0.0));
		var direction = (next_position - translation).normalized();
		var dist = unit_speed * delta * (0.5 if slow_timer > 0.0 else 1.0);
		var result = move_and_slide(direction * dist, Vector3(0.0, 1.0, 0.0));
		if result.length() > dist * 0.5:
			
			slow_timer = 0.1;
		if translation.distance_squared_to(next_position) < 0.01:
			
			path_traversed += 1;
		
	else:
		
		path = null;
	
	return;

func on_enemy_damage(damage_amount):
	
	unit_health -= damage_amount;
	health.region_rect.size.x = (unit_health / unit_max_health) * 64.0;
	if unit_health < 0.0:
		
		queue_free();
	
	return;

func process_damage(delta):
	
	var enemy = null;
	for body in area.get_overlapping_bodies():
		
		if body.has_method("on_unit_damage"):
			
			if enemy == null || body.unit_health > enemy.unit_health:
				
				enemy = body;
	
	if enemy != null:
		
		enemy.on_unit_damage(unit_damage * delta);
	
	return;

func process_movement(delta):
	
	traverse_path(delta);
	return;

func _process(delta):
	
	process_movement(delta);
	process_damage(delta);
	return;