extends CharacterBody2D


const SPEED = 2500.0
const HEALTH_MAX = 100

@onready var animatedSprite2D = $AnimatedSprite2D
@onready var hitbox = $CollisionShape2D
@onready var weaponHitBoxFrame6 = $weapon/hitBoxFrame6
@onready var weaponHitBoxFrame7 = $weapon/hitBoxFrame7
@onready var healthBar = $healthBar/ProgressBar
@onready var player = get_tree().root.get_node("Node2D/medevialWarrior")

var health: int = 100;
var isDead: bool = false;
var latestAnimationEnded : bool = true
var direction: int = 1
var rng: RandomNumberGenerator = RandomNumberGenerator.new()
var protected: bool = false

func _ready() -> void:
	healthBar.value = health

func _process(delta: float) -> void:
	if (isDead):
		return

	if (latestAnimationEnded):
		get_node("weapon/hitBoxFrame6").set_deferred("disabled", true)
		get_node("weapon/hitBoxFrame7").set_deferred("disabled", true)
		protected = false
		var distanceToPlayer: float = calculateDistance(player.position, position);
		if (player.getIsDead() || distanceToPlayer >= 350.0):
			chill()
		else:
			attackPlayer(delta, distanceToPlayer)
	elif (animatedSprite2D.animation == "attack"):
		match animatedSprite2D.frame:
			6:
				get_node("weapon/hitBoxFrame6").set_deferred("disabled", false)
			7:
				get_node("weapon/hitBoxFrame6").set_deferred("disabled", true)
				get_node("weapon/hitBoxFrame7").set_deferred("disabled", false)
			_:
				get_node("weapon/hitBoxFrame6").set_deferred("disabled", true)
				get_node("weapon/hitBoxFrame7").set_deferred("disabled", true)

func calculateDistance(positionA: Vector2, positionB: Vector2) -> float:
	return (sqrt(pow(positionB.x - positionA.x, 2) + pow(positionB.y - positionA.y, 2)))

func attackPlayer(delta: float, distanceToPlayer: float) -> void:
	if (distanceToPlayer > 100):
		move(delta)
	else:
		fightPlayer()
	
func move(delta: float) -> void:
	var newDirection: int
	if (position.x - player.position.x > 0):
		newDirection = -1
	else:
		newDirection = 1
	if (newDirection != direction):
			animatedSprite2D.flip_h = !animatedSprite2D.flip_h
			weaponHitBoxFrame6.scale.x = -weaponHitBoxFrame6.scale.x
			weaponHitBoxFrame7.scale.x = -weaponHitBoxFrame7.scale.x
			direction = newDirection
	animatedSprite2D.play("walk")
	velocity = Vector2(direction, 0) * SPEED * delta
	move_and_slide()

func fightPlayer() -> void:
	#idea : the lower the health of the enemy is, the slower he will take decision
	var random = rng.randi_range(0, 1)
	match random:
		0:
			attack()
		1:
			shield()

func attack() -> void:
	animatedSprite2D.play("attack")
	latestAnimationEnded = false;

func shield() -> void:
	animatedSprite2D.play("shield")
	protected = true;
	latestAnimationEnded = false;
	
func chill() -> void:
	animatedSprite2D.play("idle")
	
func takeDamage() -> void:
	#idea : add a parameter "attackDirection", and if the enemy is protected and face the good direction, he protect himself
	if (isDead || protected):
		return ;
	health -= 50;
	healthBar.value = health
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


func _on_weapon_body_entered(body):
	if (body.is_in_group("player")):
		body.takeDamage()
