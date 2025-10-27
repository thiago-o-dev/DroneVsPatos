extends Control

@export var submit: Button
@export var json_text_edit: TextEdit

func _ready():
	# Properly connect the button press signal
	submit.pressed.connect(_on_button_pressed)

func _on_button_pressed():
	validate_json()

func validate_json():
	var json_str: String = json_text_edit.text.strip_edges()

	# If empty, create a random example JSON
	if json_str == "":
		json_str = '{
  "drone_brand": "PatoX",
  "drone_modelId": "patox-alpha",
  "drone_serial": "PTX-ALPHA-001",
  "drone_velocidade": 5,
  "drone_danoTiro": 5,
  "drone_taxaTiro": 5,
  "drone_cortaVento": 5,
  "drone_resistencia": 5,
  "drone_precisao": 5,
  "drone_turbo_potencia": 8,
  "drone_turbo_estoque": 6,
  "drone_turbo_producao": 5,
  "pato_height": 100,
  "pato_weight": 5000,
  "pato_hibernation": 1,
  "pato_bpm": 40,
  "pato_mutation_score": 0,
  "pato_mutation_tier": "Comum",
  "pato_superpower_name": "Hyper Raio",
  "pato_superpower_description": "Dispara feixes de energia concentrada.",
  "origin_country": "Brasil",
  "location_city": "Marília",
  "location_country": "Brasil",
  "location_lat": -22.2,
  "location_lon": -49.9,
  "location_landmark": "",
  "pato_superpower": 0
}'

	# Parse the JSON safely
	var parsed = JSON.new()
	var error = parsed.parse(json_str)
	
	if error == OK:
		var result = parsed.data
		
		if typeof(result) == TYPE_DICTIONARY:
			print("Drone Brand:", result["drone_brand"])
			print("Superpower:", result["pato_superpower_name"])
			print("Location:", result["location_city"], ",", result["location_country"])
			
			# Example: Send this to a global singleton or next scene
			Global.json = result
			get_tree().change_scene_to_file("res://scenes/bullethell_game.tscn")
			
		else:
			print("❌ JSON is valid but not a dictionary!")
	else:
		print("❌ Failed to parse JSON!")
		print("Error:", parsed.get_error_message())
		print("At line:", parsed.get_error_line())
		# Optionally: show a warning popup
