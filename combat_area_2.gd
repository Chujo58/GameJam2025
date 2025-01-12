extends Area2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	var enemies_left = get_tree().get_nodes_in_group("enemy").size()
	print(enemies_left)
	if enemies_left <= 0 and not $"../test_character".isInSpawn:
		$"../Doors".enabled = false

func _on_body_entered(body: Node2D) -> void:
	var enemy_arr:Array[String] = ["chicken"]
	if body.name == "test_character":
		print("entered combat room 3")
		$"../Doors".enabled = true
		$"..".spawn_enemies(Vector2(2125, -300), Vector2(2600,175), enemy_arr)
		#close door
		#spawn enemies
	
