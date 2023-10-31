extends Control

const GAME_SCENE = "res://scenes/mainScene.tscn"
const MELEE_CHARACTER = preload("res://scenes/medevial_warrior.tscn")
const RANGE_CHARACTER = preload("res://scenes/archer.tscn")

func loadNewScene(character: Object) -> void:
	Global.character_choose = character
	get_tree().change_scene_to_file(GAME_SCENE)

func _on_melee_character_button_pressed() -> void:
	loadNewScene(MELEE_CHARACTER)

func _on_range_character_button_pressed() -> void:
	loadNewScene(RANGE_CHARACTER)
