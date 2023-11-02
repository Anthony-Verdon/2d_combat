extends Node2D

func _ready():
	add_child(Global.character_choose.instantiate())
