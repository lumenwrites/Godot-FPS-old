extends Area


func _on_Ladder_body_entered(body):
	if body is Player:
		body.do_climb = true


func _on_Ladder_body_exited(body):
	if body is Player:
		body.do_climb = false
