extends CharacterBody2D

var HP = 10
var speed = 100

@export var player: Node2D


func _ready() -> void:
	add_to_group("enemy")



func _physics_process(delta):
	if player:
		var dir_to_player = (player.global_position - global_position).normalized()
		velocity = dir_to_player * speed
		move_and_slide()

func take_damage(damage_amount: int) -> void:
	HP -= damage_amount
	if HP <= 0:
		queue_free()
