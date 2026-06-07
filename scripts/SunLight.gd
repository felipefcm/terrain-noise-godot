extends DirectionalLight3D

@export var speed: float = 0.5;

var direction: int = -1;
var moving := false;

func _unhandled_input(event):
	if(event is InputEventKey):
		if(event.keycode == KEY_M):
			moving = !moving;

func _process(delta):
	
	if(!moving): return;

	rotate_x(speed * direction * delta);
	
	if(direction == -1 && rotation_degrees.x <= -170.0):
		direction = 1; return;

	if(direction == 1 && rotation_degrees.x >= -10.0):
		direction = -1; return;
