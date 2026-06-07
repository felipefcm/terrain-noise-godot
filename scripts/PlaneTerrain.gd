extends MeshInstance3D

@export var sizeX: int = 384
@export var sizeZ: int = 384
@export var heightMultiplier: float = 50.0
@export var mapSize: Vector2 = Vector2(128, 128)
@export var heightExponent: float = 1.8
@export var warpStrength: float = 10.0

@export var water: Color
@export var sand: Color
@export var dirt: Color
@export var grass: Color
@export var forest: Color
@export var rock: Color
@export var ice: Color

var elevationNoise: FastNoiseLite
var moistureNoise: FastNoiseLite
var warpNoise: FastNoiseLite

func _ready():
	elevationNoise = FastNoiseLite.new()
	elevationNoise.seed = randi()
	elevationNoise.fractal_type = FastNoiseLite.FRACTAL_FBM
	elevationNoise.fractal_octaves = 6
	elevationNoise.fractal_lacunarity = 2.0
	elevationNoise.fractal_gain = 0.5

	moistureNoise = FastNoiseLite.new()
	moistureNoise.seed = randi()
	moistureNoise.fractal_octaves = 5
	moistureNoise.fractal_lacunarity = 2.0
	moistureNoise.fractal_gain = 0.5

	warpNoise = FastNoiseLite.new()
	warpNoise.seed = randi()
	warpNoise.fractal_octaves = 3
	warpNoise.frequency = 0.008

	mesh = generate()

func generate() -> Mesh:
	var planeMesh = PlaneMesh.new()
	planeMesh.size = mapSize
	planeMesh.subdivide_width = sizeX
	planeMesh.subdivide_depth = sizeZ

	var mdt := MeshDataTool.new()
	var st := SurfaceTool.new()

	# Pass 1: assign heights
	st.create_from(planeMesh, 0)
	mdt.create_from_surface(st.commit(), 0)

	for i in range(mdt.get_vertex_count()):
		var v = mdt.get_vertex(i)
		v.y = getHeight(v)
		mdt.set_vertex(i, v)

	var heightMesh := ArrayMesh.new()
	mdt.commit_to_surface(heightMesh)

	# Pass 2: generate normals
	st.create_from(heightMesh, 0)
	st.generate_normals()
	mdt.create_from_surface(st.commit(), 0)

	# Pass 3: assign colors using height + slope derived from normals
	for i in range(mdt.get_vertex_count()):
		var v = mdt.get_vertex(i)
		var normal = mdt.get_vertex_normal(i)
		mdt.set_vertex_color(i, getVertexColor(v, normal))

	var finalMesh := ArrayMesh.new()
	mdt.commit_to_surface(finalMesh)
	return finalMesh

func getHeight(position: Vector3) -> float:
	var warp_x = warpNoise.get_noise_2d(position.x, position.z)
	var warp_z = warpNoise.get_noise_2d(position.x + 5.2, position.z + 1.3)
	var wx = position.x + warp_x * warpStrength
	var wz = position.z + warp_z * warpStrength
	var raw = max(0.0, elevationNoise.get_noise_2d(wx, wz))
	return pow(raw, heightExponent) * heightMultiplier

func getVertexColor(vertex: Vector3, normal: Vector3) -> Color:
	var height = vertex.y / heightMultiplier
	var moisture = max(0.0, moistureNoise.get_noise_2d(vertex.x, vertex.z))
	var slope = 1.0 - normal.y  # 0 = flat, approaches 1 = vertical cliff

	if height <= 0.0:
		return water
	if height < 0.04:
		return water.lerp(sand, smoothstep(0.0, 0.04, height))
	if height < 0.08:
		return sand.lerp(dirt, smoothstep(0.04, 0.08, height))

	var biome_color = grass.lerp(forest, smoothstep(0.2, 0.4, moisture))

	if height < 0.35:
		var rock_t = smoothstep(0.3, 0.55, slope)
		return biome_color.lerp(rock, rock_t)

	if height < 0.6:
		var highland_t = smoothstep(0.35, 0.6, height)
		var rock_t = maxf(highland_t, smoothstep(0.3, 0.55, slope))
		return biome_color.lerp(rock, rock_t)

	return rock.lerp(ice, smoothstep(0.6, 0.8, height))
