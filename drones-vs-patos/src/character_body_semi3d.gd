extends CharacterBody3D

@export var speed = 5.0
@export var air_drag = 5.0
@export var movement_limit : PlaneMesh

func _physics_process(delta):
	# Add the gravity.
	#if not is_on_floor():
		#velocity += get_gravity() * delta

	# Handle jump.
	#if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		#velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir = Input.get_vector("ui_left", "ui_right", "ui_down", "ui_up")
	#var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	var direction = (Vector3(input_dir.x, input_dir.y, 0)).normalized()
	if direction:
		velocity = direction * speed
	else:
		velocity.x = move_toward(velocity.x, 0, speed)
		velocity.y = move_toward(velocity.y, 0, speed)

	move_and_slide()
	
	position = clamp_to_box(position, movement_limit.size, movement_limit.center_offset)

func clamp_to_box(pos: Vector3, size: Vector2, center: Vector3) -> Vector3:
	return Vector3(
		clamp(pos.x, center.x - size.x/2, center.x + size.x/2),
		clamp(pos.y, center.z - size.y/2, center.z + size.y/2),
		pos.z
	)
