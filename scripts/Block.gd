extends CSGBox3D

var targetHeight = 0;
@export var rate: float = 2;

func _process(delta):
	if (!Simulator.startedAnimation): return ;

	if (height >= targetHeight): return ;

	height += rate * delta;
	position.y += delta * rate / 2;
