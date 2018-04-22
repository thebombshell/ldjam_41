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
	
	return;

func _process(delta):
	
	process_movement(delta);
	process_damage(delta);
	return;