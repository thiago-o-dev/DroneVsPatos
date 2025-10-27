extends Node3D

@export var rotation_speed : float = 1
@export var rotation_direction : Vector3

func _physics_process(delta):
	rotation += rotation_direction.normalized() * rotation_speed * delta
