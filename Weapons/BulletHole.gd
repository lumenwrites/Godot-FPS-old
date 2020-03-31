extends Spatial

func _ready():
	$AnimationPlayer.play("bullet_hole_fade")

func _on_AnimationPlayer_animation_finished(anim_name):
	queue_free()
