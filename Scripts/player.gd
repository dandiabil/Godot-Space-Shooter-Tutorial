class_name Player extends CharacterBody2D

signal laser_shot(laser_scene, laser_position)
signal killed

@export var SPEED = 300.0

@onready var muzzle = $Muzzle

var laser_scene = preload("res://Scenes/laser.tscn")

var shoot_cooldown = false

func _process(delta):
	if Input.is_action_pressed("shoot"):
		if !shoot_cooldown:
			shoot_cooldown = true
			shoot()
			await get_tree().create_timer(0.25).timeout
			shoot_cooldown = false

func _physics_process(_delta):
	var direction = Vector2(Input.get_axis("move_left", "move_right"), Input.get_axis("move_up", "move_down"))
	velocity = direction * SPEED
	
	move_and_slide()
	
	global_position = global_position.clamp(Vector2.ZERO, get_viewport_rect().size)

func shoot():
	laser_shot.emit(laser_scene, muzzle.global_position)

func die():
	killed.emit()
	queue_free()
