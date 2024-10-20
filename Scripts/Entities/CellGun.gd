@tool
extends Cell
class_name CellGun

signal shoot_finish(cell: CellGun)

@onready var animator: AnimationPlayer = $AnimationPlayer
@onready var charger: GPUParticles2D = $GPUParticles2D

@export var is_shooting: bool = true

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
  pass # Replace with function body.

func arm_weapons(arm: bool):
  charger.emitting = arm

func shoot():
  is_shooting = true
  animator.play("Fire")
  await animator.animation_finished
  is_shooting = false
  shoot_finish.emit(self)

func inflict_damage():
  print("BANG!")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
  pass

func _on_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
  if event is InputEventMouseButton and event.is_pressed():
    cell_clicked.emit(self)
