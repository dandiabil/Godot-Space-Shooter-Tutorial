extends Control

@onready var score = $Score:
	set(value):
		score.text = "Score: " + str(value)


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
