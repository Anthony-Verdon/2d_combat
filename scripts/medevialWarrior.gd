extends CharacterBody2D

const SPEED = 10000.0

@onready var animatedSprite2D = $AnimatedSprite2D
@onready var weaponHitBox = $weapon/CollisionPolygon2D
@onready var healthBar = $healthBar/ProgressBar

var latestAnimationEnded : bool = true
var direction: int = 1
var isDead: bool = false
var health: int = 100

func _ready() -> void:
	healthBar.value = health

func _process(delta) -> void:
	if (isDead):
		return
	
	if (Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT)):
		attack();
	elif (latestAnimationEnded):
		get_node("weapon/CollisionPolygon2D").set_deferred("disabled", true)
		var directionX: int = 0
		if (Input.is_key_pressed(KEY_A) || Input.is_key_pressed(KEY_LEFT)):
			directionX -= 1
		if (Input.is_key_pressed(KEY_D) || Input.is_key_pressed(KEY_RIGHT)):
			directionX += 1
		updatePosition(directionX, delta)
		updateAnimation(directionX)
	elif (animatedSprite2D.animation == "attack1" && animatedSprite2D.frame == 2):
		get_node("weapon/CollisionPolygon2D").set_deferred("disabled", false)
	

func attack() -> void:
	animatedSprite2D.play("attack1")
	latestAnimationEnded = false;

func updatePosition(directionX: int, delta: float) -> void:
	velocity = Vector2(directionX, 0) * SPEED * delta
	move_and_slide()

func updateAnimation(directionX: int) -> void:
	if (directionX != 0):
		animatedSprite2D.play("run2")
		if (directionX != direction):
			animatedSprite2D.flip_h = !animatedSprite2D.flip_h
			weaponHitBox.scale.x = -weaponHitBox.scale.x
			direction = directionX
	else:
		animatedSprite2D.play("idle")

func takeDamage() -> void:
	if (isDead || !latestAnimationEnded):
		return ;
	health -= 50;
	healthBar.value = health
	if (health <= 0):
		die();
	else:
		animatedSprite2D.play("takeDamage")
		latestAnimationEnded = false

func die() -> void:
	animatedSprite2D.play("death")
	isDead = true;
	get_node("CollisionShape2D").set_deferred("disabled", true)

func _on_animated_sprite_2d_animation_finished():
	latestAnimationEnded = true;

func getIsDead() -> bool:
	return (isDead)

func _on_weapon_body_entered(body):
	if (body.is_in_group("enemy")):
		body.takeDamage();
