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
@onready var attackHitbox1 = $weapon/attackHitbox1
@onready var attackHitbox2 = $weapon/attackHitbox2
@onready var attackHitbox3 = $weapon/attackHitbox3
@onready var healthBar = $statisticsBars/healthBar
@onready var energyBar = $statisticsBars/energyBar

var latestAnimationEnded : bool = true
var actual_direction: int = 1
var isDead: bool = false
var health: float = HEALTH_MAX
var energy: float = ENERGY_MAX
var timer: float = 0
var attackCount: int = 0
var timePast: float = 0
var lastAttackTiming: float = 0

func _ready() -> void:
	healthBar.value = health
	energyBar.value = energy

func _process(delta) -> void:
	if (isDead):
		return

	timePast += delta
	var direction: Vector2 = Vector2(Input.get_axis("ui_left", "ui_right"), 0)
	if (is_on_floor()):
		checkPlayerAction(timePast)
	regenEnergy(delta)
	updatePosition(direction, delta)
	updateAnimation(direction)
	updateWeaponHitbox()

func regenEnergy(delta: float) -> void:
	timer += delta
	if (timer < 3.0):
		return
	timer -= 3.0
	energy += 10
	if (energy > 100):
		energy = 100
	energyBar.value = energy

func checkPlayerAction(timePast: float) -> void:
	if (Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT)):
		attack(timePast);
	elif (Input.is_key_pressed(KEY_SPACE)):
		jump();
	elif (Input.is_key_pressed(KEY_SHIFT)):
		roll();

func attack(timePast: float) -> void:
	if (!latestAnimationEnded || energy < 10):
		return
	
	if (timePast - lastAttackTiming > 1):
		attackCount = 0
	lastAttackTiming = timePast
	attackCount += 1
	animatedSprite2D.play("attack" + str(attackCount))
	if (attackCount == 3):
		attackCount = 0
	latestAnimationEnded = false;
	energy -= 10
	energyBar.value = energy

func jump() -> void:
	if (!is_on_floor()  || energy < 20):
		return
	velocity.y = JUMP_VELOCITY
	energy -= 20
	energyBar.value = energy

func roll() -> void:
	if (!latestAnimationEnded || energy < 10):
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
			attackHitbox1.scale.x = -attackHitbox1.scale.x
			attackHitbox2.scale.x = -attackHitbox2.scale.x
			attackHitbox3.scale.x = -attackHitbox3.scale.x
			actual_direction = int(direction.x)
	else:
		animatedSprite2D.play("idle")
	if not is_on_floor():
		if (velocity.y < 0):
			animatedSprite2D.play("jump")
		else:
			animatedSprite2D.play("fall")

func updateWeaponHitbox() -> void:
	if (latestAnimationEnded || animatedSprite2D.frame != 2):
		attackHitbox1.set_deferred("disabled", true)
		attackHitbox2.set_deferred("disabled", true)
		attackHitbox3.set_deferred("disabled", true)
		return
	if (animatedSprite2D.animation == "attack1"):
		attackHitbox1.set_deferred("disabled", false)
	elif (animatedSprite2D.animation == "attack2"):
		attackHitbox2.set_deferred("disabled", false)
	elif (animatedSprite2D.animation == "attack3"):
		attackHitbox3.set_deferred("disabled", false)
		
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
	attackHitbox1.set_deferred("disabled", true)
	attackHitbox2.set_deferred("disabled", true)
	attackHitbox3.set_deferred("disabled", true)
	energyBar.value = 0

func _on_animated_sprite_2d_animation_finished():
	latestAnimationEnded = true;

func _on_weapon_body_entered(body):
	if (body.is_in_group("enemy")):
		body.takeDamage();

func getIsDead() -> bool:
	return (isDead)
