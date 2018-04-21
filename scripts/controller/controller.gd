extends Spatial

# constants

const Selectable = preload("res://scripts/unit/selectable.gd");

const scroll_dist = 100.0;
const scroll_speed = 2.0;

const select_project_dist = 32.0;

# absolute objects

# child objects

onready var camera = get_node("Camera");
onready var select = get_node("Select");
onready var select_box = get_node("Select/Box");
onready var center_box = get_node("UI/Container/Center");
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

# scrolling vars

var scroll_center = Vector2(0.0, 0.0);

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

func center_input(event):

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
				for body in selectables:

					var coord = camera.unproject_position(body.translation);
					if select_rect.intersects(Rect2(coord - Vector2(8.0, 8.0), Vector2(16.0, 16.0))):

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
				
				var origin = camera.project_ray_origin(event.position);
				var normal = camera.project_ray_normal(event.position);
				var state = get_world().direct_space_state;
				var result = state.intersect_ray(origin, origin + normal * 128.0);
				if !result.empty():
					var point = result.position + Vector3(0.0, 1.0, 0.0);
					for body in selected_bodies:
						
						body.selectable_move_order(point);
	
	elif event is InputEventMouseMotion:
		
		if  Input.is_action_pressed("mouse_left"):
			end = get_viewport().get_mouse_position();
	
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
