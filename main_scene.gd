extends Node2D

# add global variables here
var chicken_enemy_scene = preload("res://chickenEnemy.tscn")


# default functions that are useful
func _ready() -> void:
	$test_character/HealthBar/ProgressBar.value = $test_character.HP


func _physics_process(delta: float) -> void:
	pass




func spawn_enemy():
	var new_enemy = chicken_enemy_scene.instantiate()
	add_child(new_enemy)
	new_enemy.global_position = Vector2(300, 300)
