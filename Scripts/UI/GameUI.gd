extends Node
class_name GameUI

signal resolve()

enum State{DEFAULT, SELECTING, SELECTING_MOVE, SELECTING_BREAK, WAITING}

@export var controller: ControllerUI
@export var state: State = State.DEFAULT

@onready var selector: Control = $SelectorBox

var selected_drone: Drone
var selected_component: Node2D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
  pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
  pass

func _on_resolve_click():
  state = State.DEFAULT
  controller.submit_command()
  resolve.emit()
  pass

func _on_resolve_finish(drones: Array[Drone]):
  state = State.DEFAULT
  controller.commands = []
  pass

func _on_drone_click(drone:Drone, component: Node2D):
  match state:
    State.DEFAULT:
      state = State.SELECTING
      selected_drone = drone
      selected_component = component
      selector.position = get_viewport().get_mouse_position()
    State.SELECTING:
      selected_drone = drone
      selected_component = component
      selector.position = get_viewport().get_mouse_position()
      # Move selection window..

