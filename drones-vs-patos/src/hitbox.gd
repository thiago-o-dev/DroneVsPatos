class_name HitBox
extends Area3D

@export var damage : float = 0

func set_activitiy(state : bool):
	monitorable = state
	monitoring = state
