class_name Enemy extends Area2D

signal laser_shot(laser_scene, laser_position)
signal killed
signal hit

@export var SPEED = 150.0
@export var HP = 1
@export var POINTS = 100

@onready var muzzle = $Muzzle

var laser_scene = preload("res://Scenes/laser.tscn")

#var shoot_cooldown = false

#func _process(delta):
	#if Input.is_action_pressed("shoot"):
		#if !shoot_cooldown:
			#shoot_cooldown = true
			#shoot()
			#await get_tree().create_timer(0.25).timeout
			#shoot_cooldown = false

func _physics_process(delta):
	global_position.y += SPEED * delta

func shoot():
	laser_shot.emit(laser_scene, muzzle.global_position)

func die():
	queue_free()

func _on_body_entered(body):
	if body is Player:
		body.die()
		queue_free()


func _on_visible_on_screen_notifier_2d_screen_exited():
	queue_free()

func take_damage(amount):
	HP -= amount
	if(HP <= 0):
		killed.emit(POINTS)
		die()
	else:
		hit.emit()
