extends Node2D
class_name Boid

var rules = []
var Velocity: Vector2
@export var avoid_factor = 0.02
@export var match_factor = 0.05
@export var centering_factor = 0.00025

@onready var detector = $DetectArea
@onready var safety_zone = $BoidArea
@onready var sprite_rot = $Node2D
@onready var sprite = $Node2D/Sprite2D

var EdgeMargin = 100

var MaxPos: Vector2
var Size: Vector2

var following_mouse = false

func setup(follow):
	following_mouse = follow

# Called when the node enters the scene tree for the first time.
func _ready():
	randomize_Velocity()
	if following_mouse:
		rules.append(follow_mouse)
	else:
		rules.append(separate)
		rules.append(avoidMouse)
		rules.append(alignAndCenter)
	
	DisplayServer.window_get_size()
	MaxPos = get_viewport().get_visible_rect().size
	
	rules.append(avoid_walls)
	rules.append(clamp_speeds)
	
func get_heading():
	return atan2(Velocity.y, Velocity.x)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	calc_velocity()
	translate(Velocity)
	if Velocity.x != 0 && Velocity.y != 0:
		sprite_rot.rotation = get_heading()
	
func calc_velocity():
	for rule in rules:
		rule.call()
	return Velocity
	
func randomize_Velocity():
	Velocity = Vector2(randf() * 2 - 1, randf() * 2 - 1) * 10

func find_neighbors():
	return detector.get_overlapping_areas()

func separate():
	var neighbors = safety_zone.get_overlapping_areas()
	var close = Vector2.ZERO
	for neighbor in neighbors:
		close += (global_position - neighbor.global_position)
	
	Velocity += close * avoid_factor
	
func avoidMouse():
	var distance = get_global_mouse_position().distance_to(global_position)
	if distance < 300:
		Velocity += (global_position - get_global_mouse_position()) * avoid_factor
	
func alignAndCenter():
	var vel = Vector2.ZERO
	var pos = Vector2.ZERO
	var neighbors = find_neighbors()
	if len(neighbors) == 0:
		return
		
	for neighbor in neighbors:
		vel += neighbor.get_parent().Velocity
		pos += neighbor.global_position
		
	Velocity += ((vel / len(neighbors)) * match_factor)
	Velocity += ((pos / len(neighbors) - position) * centering_factor)

func avoid_walls():
	var newPos = global_position + Velocity
	var acceleration = Vector2.ZERO
	var speed = .25
	
	if newPos.x < EdgeMargin:
		acceleration.x = speed
	elif newPos.x > (MaxPos.x - EdgeMargin):
		acceleration.x = -speed
	
	if newPos.y < EdgeMargin:
		acceleration.y = speed
	elif newPos.y > (MaxPos.y - EdgeMargin):
		acceleration.y = -speed
	
	Velocity += acceleration
	
func follow_mouse():
	Velocity = global_position.direction_to(get_global_mouse_position()) * global_position.distance_to(get_global_mouse_position())	
		
func clamp_speeds():
	var min_speed = 4
	var max_speed = 10
	if following_mouse:
		max_speed = 100
	var speed = sqrt(Velocity.length_squared())
	if speed == 0:
		return
	if speed > max_speed:
		Velocity *= max_speed / speed
	elif speed < min_speed:
		Velocity *= min_speed / speed
