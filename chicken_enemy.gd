extends CharacterBody2D

var HP = 10
var speed = 50

@onready var player = $"../test_character"


func _ready() -> void:
	add_to_group("enemy")



func _physics_process(delta):
	if player:
		var dir_to_player = (player.position - position).normalized()
		velocity = dir_to_player * speed
		move_and_slide()

func take_damage(damage_amount: int) -> void:
	HP -= damage_amount
	if HP <= 0:
		queue_free()


func _on_hit_box_body_entered(body: Node2D) -> void:
	if body.name == "test_character":
		body.take_damage(1)
