extends Camera3D

@export var moveSensitivity: float = 5;
@export var lookSensitivity: float = 0.1;

var forward: Vector3;

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED);
	pass;

func _process(delta: float):
	handleKey(delta);

func _unhandled_input(event):
	if(event is InputEventMouseMotion):
		handleMouseMotion(event);

func handleKey(delta: float):

	if(Input.is_action_pressed('ui_cancel')):
		get_tree().quit();
	
	var rightStr = Input.get_action_strength('ui_right');
	var leftStr = Input.get_action_strength('ui_left');
	var frontStr = Input.get_action_strength('ui_up');
	var backStr = Input.get_action_strength('ui_down');

	var up = Input.get_action_strength('fly_up');
	var down = Input.get_action_strength('fly_down');

	var motion: Vector3 = Vector3(
		rightStr - leftStr, 
		up - down, 
		backStr - frontStr
	) * moveSensitivity * delta;

	translate_object_local(motion);
	get_viewport().set_input_as_handled();

func handleMouseMotion(event: InputEventMouseMotion):
	
	var direction = event.relative;
	rotation_degrees.x += -direction.y * lookSensitivity;
	rotation_degrees.y += -direction.x * lookSensitivity;

	get_viewport().set_input_as_handled();
