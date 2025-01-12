extends Area2D





func _on_body_entered(body: Node2D) -> void:
	if body.name == "test_character":
		body.hasMelee = true
		print("Has melee now")
	queue_free()
	$"../Doors".queue_free()
