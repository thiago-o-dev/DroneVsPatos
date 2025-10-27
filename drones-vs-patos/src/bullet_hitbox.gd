extends HitBox

func _ready():
	connect("area_entered", self._on_area_entered)

func _on_area_entered(hurtbox : HurtBox):
	if hurtbox == null:
		return
		
	play_on_hit()

func play_on_hit():
	owner.queue_free()
