extends Area2D

var speed:int = 400
var damage = 1
#var direction = Vector2(1, 0) # e.g. bullet moves to the right by default
const max_pierce_count:int = 3  # How many enemies it can pierce before disappearing
var current_pierce_count:int = 0


func _physics_process(delta: float) -> void:
	position += transform.x * speed * delta



func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("enemy"):
		#print(body)
		body.take_damage(damage)
		$EnemyHitSound.play() #Play EnemyHitSound when 
		current_pierce_count += 1
		if current_pierce_count >= max_pierce_count:
			queue_free()
			
	elif "TileMapLayer" in body.name:
		queue_free()
