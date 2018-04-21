extends Spatial

# constants

const Unit = preload("res://scripts/unit/unit.gd");

const scroll_dist = 100.0;
const scroll_speed = 2.0;

const select_project_dist = 32.0;

# absolute objects

# child objects

onready var camera = get_node("Camera");
onready var select = get_node("Select");
onready var select_box = get_node("Select/Box");

# selections vars

var start = Vector2(0.0, 0.0);
var end = Vector2(0.0, 0.0);
var selected_bodies = Array();
var owned_units = Array();

# scrolling vars

var scroll_center = Vector2(0.0, 0.0);

func select_body(body):
	
	if !selected_bodies.has(body) && body.has_method("unit_set_selected"):
		
		body.unit_set_selected(true);
		selected_bodies.append(body);
	
	return;

func deselect_body(body):
	
	var index = selected_bodies.find_last(body);
	if index >= 0:
		
		body.unit_set_selected(false);
		selected_bodies.remove(index);
	
	return;

func process_screen_scroll(delta):
	
	var viewport = get_viewport();
	var mouse_pos = viewport.get_mouse_position();
	
	if Input.is_mouse_button_pressed(BUTTON_MIDDLE):
		
		var change = (mouse_pos - scroll_center) * scroll_speed * 0.1 * delta;
		translation.x += change.x;
		translation.z += change.y;
	
	if mouse_pos.x < scroll_dist:
		
		translation.x -= scroll_speed * delta;
	elif mouse_pos.x > viewport.size.x - scroll_dist:
		
		translation.x += scroll_speed * delta;
	if mouse_pos.y < scroll_dist:
		
		translation.z -= scroll_speed * delta;
	elif mouse_pos.y > viewport.size.y - scroll_dist:
		
		translation.z += scroll_speed * delta;
	
	return;

func _input(event):
	
	if event is InputEventMouseButton:
		
		if event.pressed:
			
			if event.button_index == BUTTON_LEFT:
				
				start = get_viewport().get_mouse_position();
			elif event.button_index == BUTTON_RIGHT:
				
				pass;
			elif event.button_index == BUTTON_MIDDLE:
				
				scroll_center = get_viewport().get_mouse_position();
		else:
			
			if event.button_index == BUTTON_LEFT:
				
				end = get_viewport().get_mouse_position();
				var select_rect = Rect2(Vector2(min(start.x, end.x), min(start.y, end.y)), Vector2(0.0, 0.0));
				select_rect.end = Vector2(max(start.x, end.x), max(start.y, end.y));
				for body in owned_units:
					
					var coord = camera.unproject_position(body.translation);
					if select_rect.intersects(Rect2(coord - Vector2(8.0, 8.0), Vector2(16.0, 16.0))):
						
						select_body(body);
					else:
						
						deselect_body(body);
				
			elif event.button_index == BUTTON_RIGHT:
				
				var origin = camera.project_ray_origin(event.position);
				var normal = camera.project_ray_normal(event.position);
				var state = get_world().direct_space_state;
				var result = state.intersect_ray(origin, origin + normal * 128.0);
				if !result.empty():
					var point = result.position;
					print("TRY TO CLICK");
					for body in selected_bodies:
						
						body.unit_give_order(Unit.ORDER_MOVE, point);
		
	elif event is InputEventMouseMotion:
		
		if  Input.is_action_pressed("mouse_left"):
			end = get_viewport().get_mouse_position();
	
	return;

func _ready():
	
	owned_units.append(get_node("/root/Scene/World/Unit"));
	print(owned_units);
	return;

func _process(delta):
	
	process_screen_scroll(delta);
	
	return;
