extends Spatial

# constants

const Cursor = preload("res://objects/cursor.tscn");
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
const Dialogue = preload("res://scripts/controller/dialogue.gd");
const portrait_beaming = preload("res://textures/portrait_beaming.png");
const portrait_happy = preload("res://textures/portrait_happy.png");
const portrait_upset = preload("res://textures/portrait_upset.png");
const portrait_angry = preload("res://textures/portrait_angry.png");
const sound_perfect = preload("res://sfx/dialogue-ping-01.wav");
const sound_correct = preload("res://sfx/dialogue-ping-02.wav");
const sound_wrong = preload("res://sfx/dialogue-ping-03.wav");
const sound_wierd = preload("res://sfx/dialogue-ping-04.wav");
const sound_fail = preload("res://sfx/buy-01.wav");
const sound_success = preload("res://sfx/doot.wav");
const sound_doot = preload("res://sfx/doot.wav");
const scroll_dist = 100.0;
const scroll_speed = 20.0;
const select_project_dist = 32.0;

# absolute objects

onready var world = get_node("/root/Scene/World");
onready var base = get_node("/root/Scene/World/Base");

# child objects

onready var camera = get_node("Camera");
onready var select_box = get_node("UI/SelectBox");
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
onready var gold_label = get_node("UI/Container/Top/Resources/HBoxContainer/Gold");
onready var tech_label = get_node("UI/Container/Top/Resources/HBoxContainer/Tech");
onready var happy_label = get_node("UI/Container/Top/Resources/HBoxContainer/Happiness");
onready var portrait = get_node("UI/Container/Center/Panel/VBoxContainer/TextureRect");
onready var dialogue = get_node("UI/Container/Center/Panel/VBoxContainer/Label");
onready var option_buttons = [
	get_node("UI/Container/Center/Panel/VBoxContainer/Option_0"),
	get_node("UI/Container/Center/Panel/VBoxContainer/Option_1"),
	get_node("UI/Container/Center/Panel/VBoxContainer/Option_2"),
	get_node("UI/Container/Center/Panel/VBoxContainer/Option_3")];
onready var dialogue_audio = get_node("DialogueAudio");
onready var cursor_audio = get_node("DialogueAudio");

# selections vars

var start = Vector2(0.0, 0.0);
var end = Vector2(0.0, 0.0);
var selected_bodies = Array();
var selected_actions = Array();
var selectables = Array();

# stat vars

var gold = 100;
var tech = 0;
var happy = 50;
var payout_timer = 3.0;

# scenario vars

var current_scenario = null;
var tech_streak = 0;
var wierd = 0;
var stall_timer = 3.0;

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

	var mouse_pos = get_viewport().get_mouse_position();
	
	var rect = center_box.get_global_rect();
	if !rect.has_point(mouse_pos):
		
		Input.set_custom_mouse_cursor(cursor);
		return;
	
	
	var dir = Vector2(0.0, 0.0);
	
	if Input.is_mouse_button_pressed(BUTTON_MIDDLE):
		
		if mouse_pos.x < rect.position.x + scroll_dist:
			
			dir.x -= 1.0;
		elif mouse_pos.x > rect.end.x - scroll_dist:
			
			dir.x += 1.0;
		if mouse_pos.y < rect.position.y + scroll_dist:
			
			dir.y -= 1.0;
		elif mouse_pos.y > rect.end.y - scroll_dist:
			
			dir.y += 1.0;
	else:
		
		if Input.is_key_pressed(KEY_A):
			
			dir.x -= 1.0;
		elif Input.is_key_pressed(KEY_D):
			
			dir.x += 1.0;
		if Input.is_key_pressed(KEY_W):
			
			dir.y -= 1.0;
		elif Input.is_key_pressed(KEY_S):
			
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
				select_box.rect_position = start;
				select_box.rect_size = Vector2(1.0, 1.0);
				select_box.visible = true;
			elif event.button_index == BUTTON_RIGHT:

				pass;
		else:

			if event.button_index == BUTTON_LEFT:

				select_box.visible = false;
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
				
				var mouse = get_viewport().get_mouse_position();
				var origin = camera.project_ray_origin(mouse);
				var normal = camera.project_ray_normal(mouse);
				var state = get_world().direct_space_state;
				var result = state.intersect_ray(origin + normal, origin + normal * 128.0, [], 2);
				if !result.empty():
					
					var point = result.position + Vector3(0.0, 1.0, 0.0);
					if selected_bodies.size() > 0:
						
						on_right_click(point);
	
	elif event is InputEventMouseMotion:
		
		if  Input.is_action_pressed("mouse_left"):
			
			end = get_viewport().get_mouse_position();
			select_box.rect_position = Vector2(min(start.x, end.x), min(start.y, end.y));
			select_box.rect_size = (start - end).abs();
	
	return;

func on_right_click(point):
	
	var cursor_inst = Cursor.instance();
	cursor_inst.translation = point;
	world.add_child(cursor_inst);
	cursor_audio.stream = sound_doot;
	cursor_audio.play();
	for body in selected_bodies:
		
		body.selectable_move_order(point);

func action_button(index):
	
	var success = false;
	for body in selected_bodies:
		
		success = true if body.selectable_on_action(action_buttons[index].text) else success;
	
	if success:
		
		cursor_audio.stream = sound_success;
		cursor_audio.play();
	else:
		
		cursor_audio.stream = sound_fail;
		cursor_audio.play();
	
	return;

func option_button(index):
	
	var option = option_buttons[index].text;
	if option == current_scenario[1]:
		
		tech_streak += 1;
		tech += tech_streak * 5;
		happy += 20;
		dialogue.text = "yup!";
		dialogue_audio.stop();
		dialogue_audio.stream = sound_perfect;
		dialogue_audio.play();
	elif option == current_scenario[2]:
		
		tech_streak = 0;
		happy += 10;
		dialogue.text = "hmmm";
		dialogue_audio.stop();
		dialogue_audio.stream = sound_correct;
		dialogue_audio.play();
	elif option == current_scenario[3]:
		
		tech_streak = 0;
		happy -= 5;
		dialogue.text = "shut up.";
		dialogue_audio.stop();
		dialogue_audio.stream = sound_wrong;
		dialogue_audio.play();
	elif option == current_scenario[4]:
		
		tech_streak = 0;
		happy -= 10;
		wierd += 1;
		dialogue.text = "Wait WHAT!?";
		dialogue_audio.stop();
		dialogue_audio.stream = sound_wierd;
		dialogue_audio.play();
	stall_date();
	
	return;

func process_date(delta):
	
	if stall_timer > 0.0:
		
		stall_timer -= delta;
		if stall_timer < 0.0:
			
			update_date();
	
	return;

func process_payout(delta):
	
	payout_timer -= delta;
	if payout_timer < 0.0:
		
		payout_timer = 3.0;
		if happy >= 5:
			
			gold += happy;
			happy -= 5;
		else:
			
			happy = 0.0;
			base.on_unit_damage(50.0);
	
	return;

func process_stats():
	
	gold_label.text = "gold: " + str(gold);
	tech_label.text = "tech: " + str(tech);
	happy = 0 if happy < 0 else happy;
	happy = 100 if happy > 100 else happy;
	happy_label.text = "happy: " + str(happy);
	if happy > 75:
		
		portrait.texture = portrait_beaming;
	elif happy > 50:
		
		portrait.texture = portrait_happy;
	elif happy > 25:
		
		portrait.texture = portrait_upset;
	else:
		
		portrait.texture = portrait_angry;
	return;

func stall_date():
	
	for button in option_buttons:
		
		button.disabled = true;
	stall_timer = 3.0;
	
	return;

func update_date():
	
	current_scenario = Dialogue.SCENARIOS[randi()%Dialogue.SCENARIOS.size()];
	dialogue.text = current_scenario[0];
	var pool = [1, 2, 3, 4];
	var i = 0;
	while i < 4:
		
		option_buttons[i].disabled = false;
		var index = randi()%pool.size();
		option_buttons[i].text = current_scenario[pool[index]];
		pool.remove(index);
		i += 1;
	
	return;

func _ready():
	
	center_box.connect("gui_input", self, "center_input");
	var i = 0;
	while i < action_buttons.size():
		
		action_buttons[i].connect("pressed", self, "action_button", [i]);
		i += 1;
	i = 0;
	while i < option_buttons.size():
		
		option_buttons[i].connect("pressed", self, "option_button", [i]);
		i += 1;
	
	return;

func _process(delta):

	process_screen_scroll(delta);
	process_payout(delta);
	process_date(delta);
	process_stats();
	return;
