extends ProgressBar

@export var pato : Pato

func _ready():
	max_value = pato.max_health

func _process(delta):
	if pato:
		value = pato.total_health
	else:
		value = 0
