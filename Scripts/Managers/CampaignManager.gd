extends Node


@onready var level_man: LevelManager = $LevelManager
@onready var con_ai: Controller = $ControllerAI
@onready var con_ui: Controller = $ControllerUI
@onready var ui: GameUI = $GameUI

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
  level_man.user_con = con_ui
  level_man.comp_con = con_ai
  pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
  pass
