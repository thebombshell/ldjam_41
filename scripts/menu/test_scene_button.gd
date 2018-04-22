extends Button

export(String, FILE, "*.tscn") var scene_file;

func _pressed():
	
	get_tree().change_scene(scene_file);
	return;