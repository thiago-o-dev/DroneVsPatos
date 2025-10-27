extends Node3D
class_name Attack
	
@export var spawn_rate : float = 3
@export var time_to_hit : float = 1
@export var time_to_disappear : float = 2
@export var hit_lifetime : float = 1
@export var hitbox : HitBox
var elapsed_time : float = 0
var has_started_hitbox : bool = false

func set_activity(state : bool):
	hitbox.monitorable = state
	hitbox.monitoring = state

func _ready():
	set_activity(false)

func _physics_process(delta):
	if !has_started_hitbox and elapsed_time > time_to_hit:
		has_started_hitbox = true
		set_activity(true)
	
	if elapsed_time > hit_lifetime+time_to_hit:
		set_activity(false)
	
	if elapsed_time > time_to_disappear:
		set_activity(false)
		queue_free()
		return
	
	elapsed_time += delta

# (x, y, z, z_axis_rotation)
func return_acceptable_position_and_direction() -> Vector4:
	push_warning("Unimplemented attack position")
	return Vector4.ZERO
