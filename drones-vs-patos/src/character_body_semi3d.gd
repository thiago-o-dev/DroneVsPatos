extends CharacterBody3D
class_name Drone

@export var modulate : Color = Color.WHITE
@export var shader_material : ShaderMaterial

@export_category("Health")
@export var max_health : float = 100
@onready var current_health : float = max_health

@export_category("Movement")
@export var speed = 10.0
@export var air_drag = .3
@export var movement_limit : PlaneMesh
@export var rotation_offset : Vector3
var acceleration : Vector2 = Vector2.ZERO

@export_subgroup("Dash Details")
@export var dash_speed_boost : float = 1.2
@export var dash_recharge_time_s : float = 2
@onready var _curr_dash_delay : float = dash_recharge_time_s
@export var total_dash_charges : int = 2
@onready var _curr_dash_charges : int = total_dash_charges
@export var dash_increment : int = 1

@export_category("Bullets")
@export var bullet_speed : float = 25
@export var bullet_delay : float = .5
@onready var curr_bullet_delay : float = bullet_delay
@export var bullet_inacuracy : float = .2
@onready var bullet_scene := preload("res://scenes/bullet.tscn")
@export var bullet_spawn_point : Node3D
@export var bullet_damage : float = 10

func _physics_process(delta):
	shader_material.set_shader_parameter("modulate", modulate)
	
	var input_dir = Input.get_vector("left", "right", "down", "up").normalized()
	
	acceleration = lerp(acceleration, input_dir, delta*1/air_drag)
	
	if total_dash_charges != _curr_dash_charges:
		_curr_dash_delay = max(0, _curr_dash_delay - delta)
	
	if _curr_dash_delay == 0 and _curr_dash_charges < total_dash_charges:
		_curr_dash_charges = min(total_dash_charges, _curr_dash_charges+dash_increment)
		_curr_dash_delay = dash_recharge_time_s
	
	if Input.is_action_just_pressed("dash") and input_dir != Vector2.ZERO and _curr_dash_charges > 0:
		acceleration = input_dir * dash_speed_boost
		_curr_dash_charges -= 1
		
	
	var direction = Vector3(acceleration.x, acceleration.y, 0)
	
		
	velocity = direction * speed
	rotation.z = direction.x * -.5 + rotation_offset.z
	
	curr_bullet_delay -= delta
	if Input.is_action_pressed("fire") and curr_bullet_delay < 0:
		spawn_bullet(Vector3(1, randf_range(-bullet_inacuracy, bullet_inacuracy), 0))
		curr_bullet_delay = bullet_delay
		
	move_and_slide()
	
	position = clamp_to_box(position, movement_limit.size, movement_limit.center_offset)

func clamp_to_box(pos: Vector3, size: Vector2, center: Vector3) -> Vector3:
	return Vector3(
		clamp(pos.x, center.x - size.x/2, center.x + size.x/2),
		clamp(pos.y, -center.z - size.y/2, -center.z + size.y/2),
		pos.z
	)

func spawn_bullet(direction : Vector3):
	var projectile : Bullet = bullet_scene.instantiate()
	
	add_sibling(projectile)
	
	projectile.transform = bullet_spawn_point.global_transform
	projectile.linear_velocity = direction * bullet_speed
	projectile.rotation.z = direction.normalized().y
	projectile.damage = bullet_damage

func take_damage(damage : float):
	fade_in_out(Color.RED, 0.1, 0.4)
	current_health -= damage
	
	if current_health <= 0:
		game_over()

func game_over():
	get_tree().change_scene_to_file("res://scenes/bullethell_game.tscn")

var _modulate_tween: Tween
func fade_in_out(color : Color, duration1 : float, duration2 : float):
	# If there's already an active tween, stop it
	if _modulate_tween and _modulate_tween.is_running():
		_modulate_tween.kill()  # safely stops the tween
	
	# Start a new tween
	_modulate_tween = create_tween()
	_modulate_tween.tween_property(self, "modulate", color, duration1)
	_modulate_tween.tween_property(self, "modulate", Color.WHITE, duration2)
