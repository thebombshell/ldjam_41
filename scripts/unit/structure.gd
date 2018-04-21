extends "res://scripts/unit/selectable.gd"

const DEFAULT_MAT = preload("res://materials/unit_material.tres");
const SELECTED_MAT = preload("res://materials/unit_select_material.tres");

# constants

const Unit = preload("res://objects/units/unit.tscn");

# absolute objects

onready var world = get_node("/root/Scene/World");

# child objects

onready var mesh = get_node("MeshInstance");
onready var collision = get_node("CollisionShape");

# structure vars

var order = 0;
var target = null;
var rally_point = null;

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
	
	var output = ["Build Unit"];
	return output;

func selectable_on_action(action_name):
	
	if action_name == "Destroy":
		print("I WILL NEVER DIE!!!");
	
	if action_name == "Build Unit":
		
		structure_spawn_unit(Unit);
	
	return;

# structure functions

func structure_spawn_unit(unit_node):
	
	var unit = unit_node.instance();
	var angle = rand_range(0.0, 360.0);
	unit.translation = translation + Vector3(cos(angle), 0.0, sin(angle)) * 1.5;
	world.add_child(unit);
	unit.selectable_move_order(rally_point if rally_point != null else (translation + Vector3(0.0, 0.0, 3.0)));
	
	return unit;

func _ready():
	
	collision.disabled = true;
	return;

func _process(delta):
	
	return;
