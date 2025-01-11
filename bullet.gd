extends Area2D


var speed:int = 1500
var pierceCount:int = 0

func _physics_process(delta: float) -> void:
	position += transform.x*speed*delta


func _on_area_entered(area: Area2D) -> void:
	if area.name == "":
		pierceCount += 1
	if pierceCount >= 3:
		queue_free()
