class_name HurtBox
extends Area3D

func _ready():
	connect("area_entered", self._on_area_entered)
	
func _on_area_entered(hitbox : HitBox) -> void:
	if hitbox == null:
		return
	
	#duck typing
	if owner.has_method("take_damage"):
		owner.take_damage(hitbox.damage)
	
	print(owner.name + " hurtbox got triggered")
	
	hitbox.queue_free()
