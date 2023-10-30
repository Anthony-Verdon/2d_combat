extends CharacterBody2D

const SPEED: float = 10000
const JUMP_HEIGHT: float  = 200
const JUMP_TIME_TO_PEAK: float = 0.4
const JUMP_TIME_TO_DESCENT: float = 0.5
const JUMP_VELOCITY: float = (2.0 * JUMP_HEIGHT) / JUMP_TIME_TO_PEAK * -1.0
const JUMP_GRAVITY: float = (-2.0 * JUMP_HEIGHT) / (JUMP_TIME_TO_PEAK * JUMP_TIME_TO_PEAK) * -1.0
const FALL_GRAVITY: float = (-2.0 * JUMP_HEIGHT) / (JUMP_TIME_TO_DESCENT * JUMP_TIME_TO_DESCENT) * -1.0

@onready var animatedSprite2D = $AnimatedSprite2D
@onready var weaponHitBox = $weapon/CollisionPolygon2D
@onready var healthBar = $healthBar/ProgressBar

var velocity_: Vector2 = Vector2.ZERO
var latestAnimationEnded : bool = true
var actual_direction: int = 1
var isDead: bool = false
var health: int = 100

func _ready() -> void:
	healthBar.value = health

func _process(delta) -> void:
	if (isDead):
		return
	
	var direction: Vector2 = Vector2(Input.get_axis("ui_left", "ui_right"), 0)
	if (is_on_floor()):
		checkPlayerAction()
	updatePosition(direction, delta)
	updateAnimation(direction)
	updateWeaponHitbox()

func checkPlayerAction() -> void:
	if (Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT)):
		attack();
	elif (Input.is_key_pressed(KEY_SPACE)):
		jump();

func attack() -> void:
	animatedSprite2D.play("attack1")
	latestAnimationEnded = false;

func jump() -> void:
	velocity.y = JUMP_VELOCITY

func updatePosition(direction: Vector2, delta: float) -> void:
	velocity.x = direction.x * SPEED * delta
	if (velocity.y < 0):
		velocity.y += JUMP_GRAVITY * delta
	else:
		velocity.y += FALL_GRAVITY * delta
	move_and_slide()

func updateAnimation(direction: Vector2) -> void:
	if (!latestAnimationEnded):
		return
	if (direction.x != 0):
		animatedSprite2D.play("run2")
		if (direction.x != actual_direction):
			animatedSprite2D.flip_h = !animatedSprite2D.flip_h
			weaponHitBox.scale.x = -weaponHitBox.scale.x
			actual_direction = direction.x
	else:
		animatedSprite2D.play("idle")
	if not is_on_floor():
		if (velocity.y < 0):
			animatedSprite2D.play("jump")
		else:
			animatedSprite2D.play("fall")

func updateWeaponHitbox() -> void:
	if (latestAnimationEnded):
		get_node("weapon/CollisionPolygon2D").set_deferred("disabled", true)
	elif (animatedSprite2D.animation == "attack1" && animatedSprite2D.frame == 2):
		get_node("weapon/CollisionPolygon2D").set_deferred("disabled", false)
		
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
	print(animatedSprite2D.animation)
	latestAnimationEnded = true;

func _on_weapon_body_entered(body):
	if (body.is_in_group("enemy")):
		body.takeDamage();

func getIsDead() -> bool:
	return (isDead)
