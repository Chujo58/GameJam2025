extends Area2D

var rng = RandomNumberGenerator.new()
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	rng.randomize()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_body_entered(body: Node2D) -> void:	
	if $"../test_character".clearcount >=6:
		$"../test_character".position.x = 1200
		$"../test_character".position.y = 550
	elif body.name == "test_character":
		var new_portal = $"..".validTopPortals[rng.randi() % $"..".validTopPortals.size()]
		print(new_portal)
		var new_pos = get_node("../" + new_portal).position
		$"../test_character".position.x = new_pos.x
		$"../test_character".position.y = new_pos.y + 50
