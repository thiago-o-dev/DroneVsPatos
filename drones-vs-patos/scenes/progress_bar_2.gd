extends ProgressBar

@export var drone : Drone

func _ready():
	max_value = drone.max_health

func _process(delta):
	if drone:
		value = drone.current_health
	else:
		value = 0
