extends CharacterBody2D

const SPEED = 10000.0

@onready var animatedSprite2D = $AnimatedSprite2D
@onready var weaponHitBox = $weapon/CollisionPolygon2D

var latestAnimationEnded : bool = true
var direction: int = 1

func _ready() -> void:
	pass

func _process(delta) -> void:
	if (Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT)):
		attack();
	elif (latestAnimationEnded):
		get_node("weapon/CollisionPolygon2D").set_deferred("disabled", true)
		var input_direction = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
		input_direction.y = 0;
		updatePosition(input_direction, delta)
		updateAnimation(input_direction)
	elif (animatedSprite2D.animation == "attack1" && animatedSprite2D.frame == 2):
		get_node("weapon/CollisionPolygon2D").set_deferred("disabled", false)
	

func attack() -> void:
	animatedSprite2D.play("attack1")
	latestAnimationEnded = false;

func updatePosition(input_direction: Vector2, delta: float) -> void:
	velocity = input_direction * SPEED * delta
	move_and_slide()

func updateAnimation(input_direction: Vector2) -> void:
	if (input_direction != Vector2.ZERO):
		animatedSprite2D.play("run")
		if (input_direction.x != direction):
			animatedSprite2D.flip_h = !animatedSprite2D.flip_h
			weaponHitBox.scale.x = -1
			direction = input_direction.x
	else:
		animatedSprite2D.play("idle")

func _on_animated_sprite_2d_animation_finished():
	latestAnimationEnded = true;


func _on_weapon_body_entered(body):
	if (body.is_in_group("enemy")):
		body.takeDamage();
