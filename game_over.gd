extends CanvasLayer


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_restart_pressed():
	for enemy in get_tree().get_nodes_in_group("enemy"):
		enemy.queue_free()
	$"../test_character".HP = $"../test_character".MAX_HP
	$"../test_character".hasMelee = false

	$"../test_character".hasRanged = false
	$"../test_character".hasTail = false

	$"../test_character".clearcount = 0
	$"../test_character".anShoot = true
	$"../test_character".dashing = false
	$"../test_character".isInSpawn = true

	$"../test_character".isGameOver = true

	$"../test_character".hasDied = false
	$"../test_character".position = Vector2(-737, -255)
	
