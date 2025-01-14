extends Area2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$AnimatedSprite2D.flip_h = true


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	#if $"../../..".velocity != Vector2.ZERO:
		#$"../../../AnimatedSprite2D".play("walking_no_claw")
	#else:
		#$"../../../AnimatedSprite2D".play("idle_no_claw")
		
	pass




func _on_animated_sprite_2d_animation_finished() -> void:
	queue_free()
	$"../../..".hasMelee = true


func _on_body_entered(body: Node2D) -> void:
	print(body)
	if body.is_in_group("enemy"):
		$"../../../MeleeMissAtk".stop()
		$"../../../MeleeAtk".play()
		
		body.take_damage(2)
