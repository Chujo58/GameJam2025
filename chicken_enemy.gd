extends CharacterBody2D

var HP = 15

func _ready() -> void:
	# Add this node to the "enemy" group so bullets can identify it easily.
	add_to_group("enemy")

func take_damage(damage_amount: int) -> void:
	HP -= damage_amount
	print("Enemy HP:", HP)
	if HP <= 0:
		# Handle enemy death (animation, effect, etc.)
		queue_free()
