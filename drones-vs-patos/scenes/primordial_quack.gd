extends AnimatedSprite3D
@export var hitbox : HitBox
@export var active_after_time : float = 0.15
@export var active_time : float = .5
var elapsed_time : float = 0

func _ready():
	hitbox.set_activitiy(false)
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	elapsed_time += delta
	
	if hitbox:
		#print(elapsed_time)
		if elapsed_time > active_after_time and elapsed_time < active_time:
			hitbox.set_activitiy(true)
		
		if elapsed_time > active_time:
			hitbox.set_activitiy(false)
