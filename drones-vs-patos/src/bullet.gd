extends Node3D
class_name Bullet
var linear_velocity : Vector3
@export var lifetime : float = 4
#@export var hitbox : Area3D
@export var hitbox : HitBox
var damage = 5

func _ready():
	add_to_group("Bullets")
	hitbox.damage = damage

func _process(delta):
	hitbox.damage = damage
	position += linear_velocity * delta
	lifetime -= delta
	if lifetime < 0:
		queue_free()
