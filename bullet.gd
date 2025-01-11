extends Area2D

var speed:int = 1500
var damage = 5
var direction = Vector2(1, 0) # e.g. bullet moves to the right by default
var max_pierce_count:int = 3  # How many enemies it can pierce before disappearing
var current_pierce_count:int = 0

#func _ready() -> void:
	# If you're using area_entered signal from the editor, ensure it’s connected
	# E.g. connect("area_entered", self, "_on_area_entered")

func _physics_process(delta: float) -> void:
	position += transform.x * speed * delta

func _on_area_entered(area: Area2D) -> void:
	# We only want to do something if the "area" is an enemy
	if "enemy" in area.get_groups():
		# Option A: If enemy script has a 'take_damage' method
		if area.has_method("take_damage"):
			area.take_damage(damage)
		else:
			# Option B: If enemy has an HP variable
			if area.has_variable("HP"):
				area.HP -= damage

		# After hitting an enemy, handle piercing
		current_pierce_count += 1
		if current_pierce_count >= max_pierce_count:
			queue_free()
	else:
		# If you want bullets to disappear on hitting walls or other objects, do so here
		queue_free()
