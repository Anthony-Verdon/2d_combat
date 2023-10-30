extends CharacterBody2D

const HEALTH_MAX: float = 100
const ENERGY_MAX: float = 100
const SPEED: float = 10000
const JUMP_HEIGHT: float  = 200
const JUMP_TIME_TO_PEAK: float = 0.4
const JUMP_TIME_TO_DESCENT: float = 0.5
const JUMP_VELOCITY: float = (2.0 * JUMP_HEIGHT) / JUMP_TIME_TO_PEAK * -1.0
const JUMP_GRAVITY: float = (-2.0 * JUMP_HEIGHT) / (JUMP_TIME_TO_PEAK * JUMP_TIME_TO_PEAK) * -1.0
const FALL_GRAVITY: float = (-2.0 * JUMP_HEIGHT) / (JUMP_TIME_TO_DESCENT * JUMP_TIME_TO_DESCENT) * -1.0
const ROLL_DISTANCE: float = 150

@onready var animatedSprite2D = $AnimatedSprite2D
@onready var weaponHitBox = $weapon/CollisionPolygon2D
@onready var healthBar = $healthBar/ProgressBar
@onready var energyBar = $energyBar/ProgressBar

var velocity_: Vector2 = Vector2.ZERO
var latestAnimationEnded : bool = true
var actual_direction: int = 1
var isDead: bool = false
var health: float = HEALTH_MAX
var energy: float = ENERGY_MAX
var timer: float = 0

func _ready() -> void:
	healthBar.value = health
	energyBar.value = energy

func _process(delta) -> void:
	if (isDead):
		return
	
	print(energy)
	var direction: Vector2 = Vector2(Input.get_axis("ui_left", "ui_right"), 0)
	if (is_on_floor()):
		checkPlayerAction()
	regenEnergy(delta)
	updatePosition(direction, delta)
	updateAnimation(direction)
	updateWeaponHitbox()

func regenEnergy(delta: float) -> void:
	timer += delta
	if (timer < 5.0):
		return
	timer -= 5.0
	energy += 10
	if (energy > 100):
		energy = 100
	energyBar.value = energy

func checkPlayerAction() -> void:
	if (Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT)):
		attack();
	elif (Input.is_key_pressed(KEY_SPACE)):
		jump();
	elif (Input.is_key_pressed(KEY_SHIFT)):
		roll();

func attack() -> void:
	if (!latestAnimationEnded):
		return
	animatedSprite2D.play("attack1")
	latestAnimationEnded = false;
	energy -= 10
	energyBar.value = energy

func jump() -> void:
	if (!is_on_floor()):
		return
	velocity.y = JUMP_VELOCITY
	energy -= 20
	energyBar.value = energy

func roll() -> void:
	if (!latestAnimationEnded):
		return
	animatedSprite2D.play("roll")
	latestAnimationEnded = false;
	var tween = get_tree().create_tween()
	tween.tween_property(self, "position", Vector2(position.x + ROLL_DISTANCE * actual_direction, position.y), 0.5)
	energy -= 10
	energyBar.value = energy
	
func updatePosition(direction: Vector2, delta: float) -> void:
	if (latestAnimationEnded):
		velocity.x = direction.x * SPEED * delta
	else:
		velocity.x = 0
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
			actual_direction = int(direction.x)
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
	if (isDead || animatedSprite2D.animation == "takeDamage" || animatedSprite2D.animation == "roll"):
		return ;
	health -= 50;
	healthBar.value = health
	if (health <= 0):
		die();
	else:
		animatedSprite2D.play("takeDamage")
		latestAnimationEnded = false
	energy -= 5
	energyBar.value = energy

func die() -> void:
	animatedSprite2D.play("death")
	isDead = true;
	get_node("CollisionShape2D").set_deferred("disabled", true)

func _on_animated_sprite_2d_animation_finished():
	latestAnimationEnded = true;

func _on_weapon_body_entered(body):
	if (body.is_in_group("enemy")):
		body.takeDamage();

func getIsDead() -> bool:
	return (isDead)
