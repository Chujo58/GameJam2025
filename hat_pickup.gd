extends Area2D

var ending_screen = preload("res://ending_screen.tscn")
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_body_entered(body: Node2D) -> void:
	#play end
	var end = ending_screen.instantiate()
	$"..".add_child(end)
	$"../PickupItem".play()
	$"../BossTheme".stop()
	$"../CreditTheme".play()
