extends Node2D

@export var count: int = 2;
@export var boidsScene: PackedScene
var boids = []

var _max_size: Vector2

# Called when the node enters the scene tree for the first time.
func _ready():
	DisplayServer.window_get_size()
	_max_size = get_viewport().get_visible_rect().size
	call_deferred("_spawnBoids")
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
	
func _spawnBoids():
	for i in range(count):
		var boid = boidsScene.instantiate()
		boid.setup(i == 0)
		add_sibling(boid)
		boids.append(boid)
		boid.position = generate_random_position()
	pass # Replace with function body.

func generate_random_position():
	return Vector2(_max_size.x * randf(),_max_size.y * randf())

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass
