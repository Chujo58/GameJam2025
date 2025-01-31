extends Node2D

# add global variables here
var start_menu_showing = true

var chicken_enemy_scene = preload("res://chickenEnemy.tscn")
var orange_enemy_scene = preload("res://orange_enemy.tscn")
var fish_enemy_scene = preload("res://fish_enemy.tscn")
var boss_enemy_scene = preload("res://boss.tscn")

var validLeftPortals = ["left_portal_spawn", "left_portal_upgrade_1", "left_portal_upgrade_2", "left_portal_combat_2", "left_portal_combat_4", "left_portal_combat_5"]
var validRightPortals = ["right_portal_spawn", "right_portal_upgrade_1", "right_portal_upgrade_2", "right_portal_combat_3", "right_portal_combat_5", "right_portal_combat_6"]
var validTopPortals = ["top_portal_spawn", "top_portal_upgrade_1", "top_portal_upgrade_2", "top_portal_combat_1", "top_portal_combat_4", "top_portal_combat_6"]
var validBottomPortals = ["bottom_portal_spawn", "bottom_portal_upgrade_1", "bottom_portal_upgrade_2", "bottom_portal_combat_1", "bottom_portal_combat_2"]
var enemy_spawned = 0
var rng = RandomNumberGenerator.new()
# default functions that are useful
func _ready() -> void:
	$test_character/HealthBar/ProgressBar.value = $test_character.HP
	rng.randomize()

func _physics_process(delta: float) -> void:
	pass




func spawn_enemies(top_left: Vector2, bottom_right: Vector2, enemy_scenes: Array[String]) -> void:
	var new_enemy
	if enemy_scenes[0] == "boss":
		new_enemy = boss_enemy_scene.instantiate()
		add_child(new_enemy)
		var rand_x = rng.randi_range(top_left.x, bottom_right.x)
		var rand_y = rng.randi_range(top_left.y, bottom_right.y)
		new_enemy.global_position = Vector2(rand_x, rand_y)
		return
		
	for i in 20:
		var random_scene = enemy_scenes[rng.randi() % enemy_scenes.size()]
		if random_scene == "chicken":
			new_enemy = chicken_enemy_scene.instantiate()
		elif random_scene == "orange":
			new_enemy = orange_enemy_scene.instantiate()
		elif random_scene == "fish":
			new_enemy = fish_enemy_scene.instantiate()
		

		add_child(new_enemy)

		var rand_x = rng.randi_range(top_left.x, bottom_right.x)
		var rand_y = rng.randi_range(top_left.y, bottom_right.y)
		new_enemy.global_position = Vector2(rand_x, rand_y)
