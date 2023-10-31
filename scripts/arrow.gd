extends RigidBody2D

const SPEED: int = 1000

@onready var animatedSprite2D = $AnimatedSprite2D
@onready var collisionShape2D = $CollisionShape2D

var spriteFlipped: bool = false
var actual_direction: int
var arrow_reach_ground: bool = false
func initArrow(initPosition: Vector2, direction: int) -> void:
	position = Vector2(initPosition.x, initPosition.y - 23)
	actual_direction = direction
	if (direction == -1):
		spriteFlipped = true
		center_of_mass.x = -50

func _ready() -> void:
	if (spriteFlipped):
		animatedSprite2D.flip_h = true
	animatedSprite2D.play("move")
	apply_impulse(Vector2(actual_direction * SPEED, 0))

func _on_body_entered(body):
	if (arrow_reach_ground):
		return
	if (body.is_in_group("enemy")):
		body.takeDamage()
		queue_free()
	elif (body.is_in_group("ground")):
		arrow_reach_ground = true
		animatedSprite2D.stop()
		sleeping = true
		gravity_scale = 0
		
