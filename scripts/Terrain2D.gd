extends Node3D

@export var block: PackedScene;
@export var grass: Material;
@export var dirt: Material;
@export var sand: Material;
@export var water: Material;
@export var ice: Material;

@export var width: int = 128;
@export var depth: int = 128;
@export var blockSize: float = 0.2;
@export var heightMultiplier: float = 50;
@export var minValueBump: float = 0;

var noise: FastNoiseLite;

func _ready():
	
	noise = FastNoiseLite.new();
	noise.seed = randi();
	noise.fractal_octaves = 4;
	# noise.lacunarity = 1.5;
	noise.period = 60;
	# noise.persistence = 0.2;
	# noise.
	
	generateTerrain();

func _unhandled_input(event):
	if(event is InputEventKey):
		if(event.keycode == KEY_M):
			Simulator.startedAnimation = true;

func generateTerrain():
	generateLayer(0);

func generateLayer(layer: int):
	for x in range(width):
		for z in range(depth):
			generateCell(layer, x, z);

func generateCell(_layer: int, x: int, z: int):
	
	var mapPosition = Vector3(x * blockSize, 0, -z * blockSize);
	
	var height = max(0, noise.get_noise_2d(x, z) + minValueBump) * (heightMultiplier * blockSize);
	# var height = abs(noise.get_noise_2d(x, z) + minValueBump) * (heightMultiplier * blockSize);
	
	# mapPosition.y = height / 2;
	
	var cell: CSGBox3D = block.instantiate();
	cell.width = blockSize;
	# cell.height = height;
	cell.targetHeight = height;
	cell.depth = blockSize;

	cell.material = determineCellMaterial(height);

	cell.position = to_local(mapPosition);
	add_child(cell);

func determineCellMaterial(height: float) -> Material:
	
	var cellHeight = height;
	var material;
	
	if(cellHeight <= 0): material = water;
	elif(cellHeight < 0.5): material = sand;
	elif(cellHeight < 1.0): material = dirt;
	elif(cellHeight < 8): material = grass;
	else: material = ice;

	return material;