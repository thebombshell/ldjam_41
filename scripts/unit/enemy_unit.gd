extends KinematicBody

# child objects

onready var area = get_node("Area");
onready var area_shape = get_node("Area/CollisionShape");

#

var unit_damage = 20.0;
var unit_range = 5.0;
var unit_health = 100.0;

func on_damage(damage_amount):
	
	unit_health -= damage_amount;
	if unit_health < 0.0:
		queue_free();
	return;

func process_damage(delta):
	
	area_shape.shape.radius = unit_range;
	for body in area.get_overlapping_bodies():
		
		if body.has_method("on_unit_damge"):
			
			body.on_damage += unit_damage * delta;
	
	return;

func _process(delta):
	
	process_damage(delta);
	return;