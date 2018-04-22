extends Spatial

var timer = 0.1;
func _process(delta):
	
	timer -= delta;
	scale = Vector3(1.0, 1.0, 1.0) * timer * 10.0;
	if timer <= 0.0:
		
		queue_free();
	
	return;