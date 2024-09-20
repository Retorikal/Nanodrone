extends Node

@onready var click: AudioStreamPlayer2D = get_node("Click")
@onready var damaged: AudioStreamPlayer2D = get_node("Damaged")
@onready var detach: AudioStreamPlayer2D = get_node("Detach")
@onready var move: AudioStreamPlayer2D = get_node("Move")
@onready var shoot: AudioStreamPlayer2D = get_node("Shoot")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
  pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
  pass
