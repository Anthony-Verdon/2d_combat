extends CharacterBody2D


const SPEED = 2500.0

@onready var animatedSprite2D = $AnimatedSprite2D
@onready var hitbox = $CollisionShape2D
@onready var player = get_tree().root.get_node("Node2D/medevialWarrior")

var health: int = 100;
var isDead: bool = false;
var latestAnimationEnded : bool = true

func _ready() -> void:
	animatedSprite2D.play("idle")

func _process(delta: float) -> void:
	if (isDead):
		return
	if (animatedSprite2D.animation == "attack" && (animatedSprite2D.frame == 6 || animatedSprite2D.frame == 7)):
		get_node("weapon/CollisionPolygon2D").set_deferred("disabled", false)
		return

	get_node("weapon/CollisionPolygon2D").set_deferred("disabled", true)
	var distanceToPlayer: float = calculateDistance(player.position, position);
	if (distanceToPlayer < 350.0):
		attackPlayer(delta, distanceToPlayer)
	else:
		chill()

func calculateDistance(positionA: Vector2, positionB: Vector2) -> float:
	return (sqrt(pow(positionB.x - positionA.x, 2) + pow(positionB.y - positionA.y, 2)))

func attackPlayer(delta: float, distanceToPlayer: float) -> void:
	if (distanceToPlayer > 100):
		move(delta)
	else:
		fightPlayer()
	
func move(delta: float) -> void:
	var direction: int
	if (position.x - player.position.x > 0):
		direction = -1
		animatedSprite2D.flip_h = true
	else:
		direction = 1
		animatedSprite2D.flip_h = false
	animatedSprite2D.play("walk")
	velocity = Vector2(direction, 0) * SPEED * delta
	move_and_slide()

func fightPlayer() -> void:
	attack()

func attack() -> void:
	animatedSprite2D.play("attack")
	latestAnimationEnded = false;

func chill() -> void:
	animatedSprite2D.play("idle")
	
func takeDamage() -> void:
	if (isDead):
		return ;
	health -= 50;
	if (health <= 0):
		die();
	else:
		animatedSprite2D.play("takeDamage");
		latestAnimationEnded = false

func die() -> void:
	animatedSprite2D.play("death");
	isDead = true;
	get_node("CollisionShape2D").set_deferred("disabled", true)
	
func _on_animated_sprite_2d_animation_finished():
	latestAnimationEnded = true;
