extends CharacterBody2D

var HP = 80
var speed = 75
var enemy_type = "Boss"

var random_generator = RandomNumberGenerator.new()

var current_anim = "walk"

@onready var player = $"../test_character"
var hat_pickup = preload("res://hat_pickup.tscn")

func _ready() -> void:
	add_to_group("enemy")
	$"../MainTheme".stop()
	$"../BossTheme".play()
	random_generator.randomize()

func roll_atk():
	$AnimatedSprite2D.play("roll_atk")
	$RollAtk.play()
	current_anim = "roll_atk"
	
func thorn_atk():
	$AnimatedSprite2D.play("thorn_atk")
	$ThornAtk.play()
	current_anim = "thorn_atk"

func _physics_process(delta):
	if player:
		var dir_to_player = (player.position - position).normalized()
		velocity = dir_to_player * speed
		move_and_slide()
		if !$AudioStreamPlayer2D.playing and player.HP >= 0:
			$AudioStreamPlayer2D.play()

func take_damage(damage_amount: int) -> void:
	HP -= damage_amount
	if HP <= 0:
		var hat = hat_pickup.instantiate()
		$"../".add_child(hat)
		hat.position = position
		queue_free()
		
		


func _on_hit_box_body_entered(body: Node2D) -> void:
	if body.name == "test_character":
		body.take_damage(0)


func _on_animated_sprite_2d_animation_finished() -> void:
	if current_anim == "walk":
		var ran_num = random_generator.randi_range(0,2)
		if ran_num:
			roll_atk()
		else:
			thorn_atk()
	else:
		$AnimatedSprite2D.play("walk")
		current_anim = "walk"
