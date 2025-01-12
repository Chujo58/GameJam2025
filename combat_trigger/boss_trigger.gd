extends Area2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	var enemies_left = get_tree().get_nodes_in_group("enemy").size()
	#print(enemies_left)
	if enemies_left <= 0 and not $"../test_character".isInSpawn:
		$"../Doors".enabled = false
		#spawn hat


func _on_body_entered(body: Node2D) -> void:
	var enemy_arr:Array[String] = ["boss"]
	if body.name == "test_character":
		print("entered boss room")
		$"../Doors".enabled = true
		$"..".spawn_enemies(Vector2(10000, -300), Vector2(1300,0), enemy_arr)
		$"../MainTheme".stop()
		$"../BossTheme".play()
		#close door
		#spawn enemies
	
