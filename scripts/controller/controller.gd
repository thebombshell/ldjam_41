extends Spatial

# constants

const cursor = preload("res://textures/cursor.png");
const cursor_tl = preload("res://textures/cursor_tl.png");
const cursor_tr = preload("res://textures/cursor_tr.png");
const cursor_br = preload("res://textures/cursor_br.png");
const cursor_bl = preload("res://textures/cursor_bl.png");
const cursor_t = preload("res://textures/cursor_t.png");
const cursor_r = preload("res://textures/cursor_r.png");
const cursor_b = preload("res://textures/cursor_b.png");
const cursor_l = preload("res://textures/cursor_l.png");
const Selectable = preload("res://scripts/unit/selectable.gd");
const scroll_dist = 100.0;
const scroll_speed = 20.0;
const select_project_dist = 32.0;

# absolute objects

# child objects

onready var camera = get_node("Camera");
onready var select = get_node("Select");
onready var select_box = get_node("Select/Box");
onready var ui_select_box = get_node("UI/SelectBox");
onready var center_box = get_node("UI/Container/Center/Control");
onready var action_buttons = [
	get_node("UI/Container/Bottom/Action_0"),
	get_node("UI/Container/Bottom/Action_1"),
	get_node("UI/Container/Bottom/Action_2"),
	get_node("UI/Container/Bottom/Action_3"),
	get_node("UI/Container/Bottom/Action_4"),
	get_node("UI/Container/Bottom/Action_5"),
	get_node("UI/Container/Bottom/Action_6"),
	get_node("UI/Container/Bottom/Action_7")];

# selections vars

var start = Vector2(0.0, 0.0);
var end = Vector2(0.0, 0.0);
var selected_bodies = Array();
var selected_actions = Array();
var selectables = Array();

func select_body(body):

	if !selected_bodies.has(body) && body is Selectable:

		body.selectable_set_selected(true);
		selected_bodies.append(body);

	return;

func deselect_body(body):

	var index = selected_bodies.find_last(body);
	if index >= 0:

		body.selectable_set_selected(false);
		selected_bodies.remove(index);

	return;

func process_screen_scroll(delta):

	var viewport = get_viewport();
	var mouse_pos = viewport.get_mouse_position();
	
	var rect = center_box.get_global_rect();
	if !rect.has_point(mouse_pos):
		
		Input.set_custom_mouse_cursor(cursor);
		return;
	
	
	var dir = Vector2(0.0, 0.0);
	
	if mouse_pos.x < rect.position.x + scroll_dist:
		
		dir.x -= 1.0;
	elif mouse_pos.x > rect.end.x - scroll_dist:
		
		dir.x += 1.0;
	if mouse_pos.y < rect.position.y + scroll_dist:
		
		dir.y -= 1.0;
	elif mouse_pos.y > rect.end.y - scroll_dist:
		
		dir.y += 1.0;
	
	if dir.x > 0.0:
		if dir.y > 0.0:
			Input.set_custom_mouse_cursor(cursor_br);
		elif dir.y < 0.0:
			Input.set_custom_mouse_cursor(cursor_tr);
		else:
			Input.set_custom_mouse_cursor(cursor_r);
	elif dir.x < 0.0:
		if dir.y > 0.0:
			Input.set_custom_mouse_cursor(cursor_bl);
		elif dir.y < 0.0:
			Input.set_custom_mouse_cursor(cursor_tl);
		else:
			Input.set_custom_mouse_cursor(cursor_l);
	else:
		if dir.y > 0.0:
			Input.set_custom_mouse_cursor(cursor_b);
		elif dir.y < 0.0:
			Input.set_custom_mouse_cursor(cursor_t);
		else:
			Input.set_custom_mouse_cursor(cursor);
	
	translate(Vector3(dir.x * scroll_speed * delta, 0.0, dir.y * scroll_speed * delta));
	return;

func center_input(event):

	if event is InputEventMouseButton:

		if event.pressed:

			if event.button_index == BUTTON_LEFT:

				start = get_viewport().get_mouse_position();
				ui_select_box.rect_position = start;
				ui_select_box.rect_size = Vector2(1.0, 1.0);
				ui_select_box.visible = true;
			elif event.button_index == BUTTON_RIGHT:

				pass;
		else:

			if event.button_index == BUTTON_LEFT:

				ui_select_box.visible = false;
				end = get_viewport().get_mouse_position();
				var select_rect = Rect2(Vector2(min(start.x, end.x), min(start.y, end.y)), Vector2(0.0, 0.0));
				select_rect.end = Vector2(max(start.x, end.x), max(start.y, end.y));
				for body in selectables:

					var coord = camera.unproject_position(body.translation);
					if select_rect.intersects(Rect2(coord - Vector2(16.0, 16.0), Vector2(32.0, 32.0))):

						select_body(body);
					else:

						deselect_body(body);
				selected_actions.clear();
				for body in selected_bodies:
					
					var action_names = body.selectable_get_action_names();
					for action in action_names:
						
						if !selected_actions.has(action):
							
							selected_actions.append(action);
				var i = 0;
				while i < 8:
					
					if i < selected_actions.size():
						
						action_buttons[i].disabled = false;
						action_buttons[i].text = selected_actions[i];
					else:
						
						action_buttons[i].disabled = true;
						action_buttons[i].text = "";
					i += 1;
				
			elif event.button_index == BUTTON_RIGHT:
				
				var origin = camera.project_ray_origin(get_viewport().get_mouse_position());
				var normal = camera.project_ray_normal(get_viewport().get_mouse_position());
				var state = get_world().direct_space_state;
				var result = state.intersect_ray(origin, origin + normal * 128.0);
				if !result.empty():
					var point = result.position + Vector3(0.0, 1.0, 0.0);
					for body in selected_bodies:
						
						body.selectable_move_order(point);
	
	elif event is InputEventMouseMotion:
		
		if  Input.is_action_pressed("mouse_left"):
			
			end = get_viewport().get_mouse_position();
			ui_select_box.rect_position = Vector2(min(start.x, end.x), min(start.y, end.y));
			ui_select_box.rect_size = (start - end).abs();
	
	return;

func action_button(index):
	
	for body in selected_bodies:
		
		body.selectable_on_action(action_buttons[index].text);
	return;

func _ready():
	
	center_box.connect("gui_input", self, "center_input");
	var i = 0;
	while i < action_buttons.size():
		
		action_buttons[i].connect("pressed", self, "action_button", [i]);
		i += 1;
	return;

func _process(delta):

	process_screen_scroll(delta);

	return;
