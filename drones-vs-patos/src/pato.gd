extends Node3D
class_name Pato

@export_category("Duck Controls")
@export var duck_sprites : AnimatedSprite3D
@export var ground_position : Marker3D
@export var y_movement_range : float = 20.0 # quanto ele pode se mover verticalmente
@export var player : Node3D
@export var state : DuckStates = DuckStates.STARTING
enum DuckSituation {
	HIBERNATING,
	TRANCE,
	AWAKE
}
@export var duck_situation : DuckSituation = DuckSituation.HIBERNATING

@export var max_health : float = 1000
@onready var total_health : float = max_health # * bpm/100
@export var health_to_enter_powered_up : float = 500
var is_powered : bool = false

@export_category("State Controls")
@export var patrol_speed := 2.0         # units per second (vertical nominal)
@export var max_speed := 8.0            # vertical speed clamp
@export var acceleration := 8.0         # maximum vertical acceleration (units/s^2)
@export var powering_up_duration := 1.5
@export var startup_time : float = 1.0
@export var min_distance_patrol = 4.0

@export_category("Follow Tuning")
# PD-like controller gains for better sticking to target Y
@export var follow_gain := 6.0          # proportional gain (how strongly to chase position)
@export var damping := .2             # damping factor to reduce overshoot (acts like derivative)
@export var min_arrival_threshold := 0.02

@export_category("Attack Controls")
@export var total_attack_delay : float = 6.0
@onready var attack_delay : float = total_attack_delay
@export var attack_animation_name : String = "primordial_quack"
@export var projectile_scene : PackedScene = preload("res://scenes/primordial_quack.tscn")
@export var projectile_spawn_offset : Vector3 = Vector3(0, 0, -1) # local offset from duck for spawn
@export var attack_move_speed : float = 3.0     # horizontal speed towards player while attacking
@export var attack_duration : float = 1      # how long the attack state lasts
@export var attack_time_to_instantiate : float = .5
@export var attack_follow_y : bool = false       # toggle: if false, duck won't adjust Y while attacking
@export var attack_lifetime : float = 1
@export var attack_time_to_adjust : float = 2

@export_subgroup("Random Attacks")
enum PowerEnum {
	HYPER_BEAM,
	THUNDER_RAIN,
	MAGIC_FOREST
}
@export var special_power : PowerEnum = PowerEnum.HYPER_BEAM

func activate_power():
	match special_power:
		PowerEnum.HYPER_BEAM:
			attack_follow_y = true
			total_attack_delay = 2
			attack_move_speed = 6
			projectile_scene = preload("res://scenes/hyper_beam.tscn")
			
			attack_delay = total_attack_delay

#@export var random_attack_scenes : AttackData

# runtime
var velocity_y: float = 0.0
var target_y: float = 0.0
var state_time := 0.0
var state_duration := 0.0
var rng := RandomNumberGenerator.new()

enum DuckStates {
	STARTING,
	PATROL,
	TARGETING_PLAYER,
	POWERING_UP,
	ATTACKING
}

# Called when the node enters the scene tree for the first time.
func _ready():
	rng.randomize()
	# initialize vertical position target to current clamped Y
	target_y = _clamped_y(global_transform.origin.y)
	_enter_state(state)

func _physics_process(delta):
	#var frameIndex: int = duck_sprites.get_frame()
	#var animationName: String = duck_sprites.animation
	#var spriteFrames: SpriteFrames = duck_sprites.get_sprite_frames()
	#var currentTexture: Texture2D = spriteFrames.get_frame_texture(animationName, frameIndex)
	
	state_time += delta
	match state:
		DuckStates.STARTING:
			_process_starting(delta)
		DuckStates.PATROL:
			_process_patrol(delta)
		DuckStates.TARGETING_PLAYER:
			_process_targeting_player(delta)
		DuckStates.POWERING_UP:
			_process_powering_up(delta)
		DuckStates.ATTACKING:
			_process_attacking(delta)

	# Apply the vertical movement (common)
	_update_vertical_position(delta)

	# decrease attack cooldown
	attack_delay = max(0.0, attack_delay - delta)

# STATE ENTER / EXIT ======================================
func _enter_state(new_state: int) -> void:
	state = new_state
	state_time = 0.0
	print("Entering state " + str(state))
	match state:
		DuckStates.STARTING:
			state_duration = startup_time
			_play_animation("default")
			# keep current Y as target
			target_y = _clamped_y(global_transform.origin.y)
		DuckStates.PATROL:
			_play_animation("default")
			_select_patrol_target_y()
			state_duration = rng.randf_range(1.0, 2.0)
		DuckStates.TARGETING_PLAYER:
			_play_animation("default")
			state_duration = attack_time_to_adjust
			fade_in_out_warn()
		DuckStates.POWERING_UP:
			state_duration = powering_up_duration
			activate_power()
			is_powered = true
		DuckStates.ATTACKING:
			# Attack runs for attack_duration (or until finished)
			state_duration = attack_duration * 3
			_play_animation(attack_animation_name)
			has_shot = false
			attack_delay = total_attack_delay

# State processors
# ----------------
func _process_starting(delta: float) -> void:
	# small vertical bobbing while waiting
	if state_time >= state_duration:
		_enter_state(DuckStates.PATROL)

func _process_patrol(delta: float) -> void:
	# move toward target_y
	_move_towards_y(target_y, patrol_speed, delta)

	# if time to pick a new patrol target, choose a new vertical position
	if state_time >= state_duration:
		_enter_state(DuckStates.PATROL)

	# become aggressive sometimes if player is near and cooldown almost ready
	if player and attack_delay < 2.0:
		_enter_state(DuckStates.TARGETING_PLAYER)

func _process_targeting_player(delta: float) -> void:
	if not player:
		_enter_state(DuckStates.PATROL)
		return

	# target a point in front of player but only set Y (use player's Y offset)
	var player_y = player.global_transform.origin.y
	var offset_y = rng.randf_range(-.5, .5)
	target_y = _clamped_y(player_y + offset_y)

	# improved follow: use desired speed proportional to distance (but clamped by max_speed)
	_move_towards_y(target_y, max_speed * 0.9, delta)
	
	if player and attack_delay == 0.0:
		_enter_state(DuckStates.ATTACKING)
		return

	# return to patrol if time over
	if state_time >= state_duration:
		_enter_state(DuckStates.PATROL)

func _process_powering_up(delta: float) -> void:
	# undamageable; when done, set powered true then go to patrol
	if state_time >= state_duration:
		is_powered = true
		_enter_state(DuckStates.PATROL)

var has_shot : bool = false
func _process_attacking(delta: float) -> void:
	if not player:
		# if player disappears, return to patrol
		_enter_state(DuckStates.PATROL)
		return

	var player_pos : Vector3 = player.global_transform.origin
	
	# Y movement during attack is controllable via attack_follow_y toggle
	target_y = _clamped_y(player_pos.y)
	
	if attack_follow_y:
		# follow player's Y but with more conservative gains so it's "sticky"
		_move_towards_y(target_y, max_speed * 0.6, delta)
	else:
		_move_towards_y(global_position.y, 0, delta)
	
	# end attack after its duration
	if not has_shot and state_time >= attack_time_to_instantiate:
		fade_in_out_attack()
		_instantiate_projectile()
		has_shot = true
	
	if state_time >= state_duration:
		_enter_state(DuckStates.PATROL)

# Damage ==================================================
var damage_tween: Tween

func take_damage(dmg: float) -> void:
	if not can_take_damage():
		# optionally play a blocked-sound or effect
		return
	
	fade_in_out_damage()
	# process HP here (not included). If you want to interrupt and power up on hit, do here.
	# Example: if hp <= 0: die()
	total_health -= dmg
	print(total_health)
	
	if total_health < health_to_enter_powered_up and !is_powered:
		_enter_state(DuckStates.POWERING_UP)
		
	if total_health < 0:
		queue_free()

# HELPERS =================================================
func can_take_damage() -> bool:
	# Only take damage in these states (customize as desired)
	return state in [DuckStates.PATROL, DuckStates.TARGETING_PLAYER, DuckStates.ATTACKING]

func fade_in_out(color : Color, duration1 : float, duration2 : float):
	# If there's already an active tween, stop it
	if damage_tween and damage_tween.is_running():
		damage_tween.kill()  # safely stops the tween
	
	# Start a new tween
	damage_tween = create_tween()
	damage_tween.tween_property(duck_sprites, "modulate", color, duration1)
	damage_tween.tween_property(duck_sprites, "modulate", Color.WHITE, duration2)

func fade_in_out_warn():
	fade_in_out(Color.YELLOW, 0.05, attack_time_to_adjust-0.05)

func fade_in_out_attack():
	fade_in_out(Color.BLUE, 0.05, attack_duration-0.05)

func fade_in_out_damage():
	fade_in_out(Color.RED, 0.1, 0.05)

func _play_animation(anim_name: String) -> void:
	if not duck_sprites:
		return
	# only play if available to avoid warnings
	duck_sprites.play(anim_name)

func force_power_up() -> void:
	_enter_state(DuckStates.POWERING_UP)

# Patrol target selection (Y only) ========================
func _select_patrol_target_y() -> void:
	var base_y := ground_position.global_transform.origin.y if ground_position else 0.0
	var min_distance := 4.0

	# Generate a new random Y within range
	var new_y := base_y + rng.randf_range(0.0, y_movement_range)
	new_y = _clamped_y(new_y)

	# Ensure it's at least 4 units from target_y
	if abs(new_y - target_y) < min_distance:
		# Push it away by min_distance in the opposite direction
		if new_y > target_y:
			new_y = target_y + min_distance
		else:
			new_y = target_y - min_distance

	# Clamp again to stay within bounds
	new_y = _clamped_y(new_y)

	target_y = new_y

# --- Projectile instantiation for attack -----------------
func _instantiate_projectile() -> void:
	if not projectile_scene:
		return
		
	var proj := projectile_scene.instantiate()
	
	add_child(proj)
	
	var t := create_tween()
	t.tween_property(proj, "modulate", Color.WHITE, attack_lifetime)
	t.connect("finished", Callable(self, "_on_projectile_tween_finished").bind(proj))

func _on_projectile_tween_finished(proj : Node):
	print("Tween animation finished!")
	proj.queue_free()

# Vertical movement helpers (PD-like controller) =========
func _move_towards_y(y: float, desired_speed: float, delta: float) -> void:
	# Use a proportional + damping approach so the duck "sticks" to the target Y with smooth acceleration
	var pos_y = global_transform.origin.y
	var error = y - pos_y

	# if almost at target, gently damp velocity toward zero
	if abs(error) < min_arrival_threshold:
		velocity_y = lerp(velocity_y, 0.0, clamp(acceleration * delta, 0.0, 1.0))
		return

	# desired velocity proportional to distance (P-term), but clamped
	var desired_v = clamp(error * follow_gain, -abs(desired_speed), abs(desired_speed))

	# damping term (D-like): subtract a factor proportional to current velocity to reduce oscillations
	var damping_effect = damping * velocity_y

	# net desired change in velocity (we treat damping as immediate desired subtract)
	var target_velocity = desired_v - damping_effect

	# accelerate toward the target_velocity but respect maximum acceleration
	velocity_y = move_toward(velocity_y, target_velocity, acceleration * delta)

	# clamp final velocity
	velocity_y = clamp(velocity_y, -max_speed, max_speed)

func _update_vertical_position(delta: float) -> void:
	# update only Y component; keep X and Z unchanged
	var pos = global_transform.origin
	pos.y += velocity_y * delta
	# clamp to allowed vertical range
	pos.y = _clamped_y(pos.y)
	# assign back
	global_transform.origin = pos

func _clamped_y(y: float) -> float:
	if ground_position:
		var base_y = ground_position.global_transform.origin.y
		return clamp(y, base_y + 0.5, base_y + y_movement_range)
	# if no ground marker, clamp to a reasonable fallback
	return y
