extends Area2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$AnimatedSprite2D.flip_h = true


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	pass


func _on_area_entered(area: Area2D) -> void:
	if area != null:
		if area.owner != null:
			if "Enemy" in area.owner.name:
				area.owner.health-=5

func _on_animated_sprite_2d_animation_finished() -> void:
	queue_free()
