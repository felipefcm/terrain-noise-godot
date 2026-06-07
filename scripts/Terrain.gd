extends Node3D

@export var block: PackedScene;
@export var grass: Material;
@export var dirt: Material;
@export var sand: Material;
@export var water: Material;
@export var ice: Material;

@export var width: int = 64;
@export var depth: int = 64;
@export var layers: int = 1;
@export var blockSize: float = 1;

var noise: FastNoiseLite;

func _ready():
	
	noise = FastNoiseLite.new();
	noise.seed = randi();
	noise.fractal_octaves = 1;
	
	generateTerrain();

func generateTerrain():
	for layer in range(layers):
		generateLayer(layer);

func generateLayer(layer: int):
	for x in range(width):
		for z in range(depth):
			generateCell(layer, x, z);

func generateCell(layer: int, x: int, z: int):
	
	var mapPosition = Vector3(x, layer, -z);
	var worldPosition = mapPosition * blockSize;
	
	var value = noise.get_noise_3dv(mapPosition);
	if(value < -0.5): return;
	
	var cell: CSGBox3D = block.instantiate();
	cell.width = blockSize;
	cell.height = blockSize;
	cell.depth = blockSize;

	cell.material = determineCellMaterial(worldPosition);

	cell.position = to_local(worldPosition);
	add_child(cell);

func determineCellMaterial(position: Vector3) -> Material:
	
	var cellHeight = position.y / blockSize;
	var material;
	
	if(cellHeight <= 0): material = water;
	elif(cellHeight < 1): material = sand;
	elif(cellHeight < 3): material = dirt;
	elif(cellHeight < 5): material = grass;
	elif(cellHeight < 7): material = ice;

	return material;