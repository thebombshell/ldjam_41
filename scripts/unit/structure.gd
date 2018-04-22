extends "res://scripts/unit/selectable.gd"

const DEFAULT_MAT = preload("res://materials/castle_mat.tres");
const SELECTED_MAT = preload("res://materials/castle_selected_mat.tres");

# constants

const Unit = preload("res://objects/units/unit.tscn");
const Worker = preload("res://objects/units/worker.tscn");
const Tank = preload("res://objects/units/tank.tscn");
const Ranger = preload("res://objects/units/ranger.tscn");

# absolute objects

onready var world = get_node("/root/Scene/World");

# child objects

onready var mesh = get_node("MeshInstance");
onready var collision = get_node("CollisionShape");
onready var health = get_node("HealthForeground");
onready var audio = get_node("AudioStreamPlayer");

# structure vars

var order = 0;
var target = null;
var rally_point = null;

var unit_max_health = 1000.0;
var unit_health = 1000.0;

func on_unit_damage(damage_amount):
	
	unit_health -= damage_amount;
	if unit_health > unit_max_health:
		
		unit_health = unit_max_health;
	health.region_rect.size.x = (unit_health / unit_max_health) * 64.0;
	if unit_health < 0.0:
		
		get_tree().change_scene("res://scenes/lose_scene.tscn");
	
	return;

# selectable functionality

func selectable_set_selected(is_selected):
	
	mesh.set_surface_material(0, SELECTED_MAT if is_selected else DEFAULT_MAT);
	return;

func selectable_give_order(new_order, new_target):
	
	order = new_order;
	target = null if order == ORDER_STOP else new_target;
	
	if order == ORDER_MOVE:
		
		rally_point = target;
	
	return;

func selectable_get_action_names():
	
	var output = ["Build Worker (50G)", "Build Ranger (100G)", "Build Tank (200G)"];
	return output;

func selectable_on_action(action_name):
	
	if action_name == "Destroy":
		
		print("I WILL NEVER DIE!!!");
		return false;
	
	if action_name == "Build Worker (50G)":
		
		if controller.gold >= 50:
			
			controller.gold -= 50;
			structure_spawn_unit(Worker);
			return true;
	
	if action_name == "Build Ranger (100G)":
		
		if controller.gold >= 100:
			
			controller.gold -= 100;
			structure_spawn_unit(Ranger);
			return true;
	
	if action_name == "Build Tank (200G)":
		
		if controller.gold >= 200:
			
			controller.gold -= 200;
			structure_spawn_unit(Tank);
			return true;
	
	return false;

# structure functions

func structure_spawn_unit(unit_node):
	
	var unit = unit_node.instance();
	var angle = rand_range(0.0, 360.0);
	unit.translation = translation + Vector3(cos(angle), 0.0, sin(angle)) * 1.5;
	world.add_child(unit);
	unit.selectable_move_order(rally_point if rally_point != null else (translation + Vector3(0.0, 0.0, 3.0)));
	
	return unit;

func _ready():
	
	return;

func _process(delta):
	
	return;
