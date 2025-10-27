extends Node3D

@export var drone : Drone
@export var pato : Pato

# Called when the node enters the scene tree for the first time.
func _ready():
	if Global.json.is_empty():
		return
	
	drone.speed = 5 + Global.json["drone_velocidade"]
	drone.bullet_damage = 3 + Global.json["drone_danoTiro"]
	drone.bullet_delay = (15 - Global.json["drone_taxaTiro"])*.025 # depois fazer algo logaritmico
	#drone.bullet_speed = 35
	drone.bullet_inacuracy = (11 - Global.json["drone_precisao"])*.015
	drone.max_health = 100 + Global.json["drone_resistencia"] * 10
	drone.air_drag = (11 - Global.json["drone_cortaVento"])*0.05
	drone.total_dash_charges = int(floor(Global.json["drone_turbo_estoque"] / 2))
	drone.dash_speed_boost = 1.2 + Global.json["drone_turbo_potencia"]*.1
	drone.dash_recharge_time_s = 2 - Global.json["drone_turbo_producao"]*.15
	
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
