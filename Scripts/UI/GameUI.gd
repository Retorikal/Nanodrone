extends Node
class_name GameUI

signal resolve()

enum State{DEFAULT, SELECTING, SELECTING_MOVE, SELECTING_BREAK, WAITING}

@export var controller: ControllerUI
@export var state: State = State.DEFAULT

@onready var split_button: Button = $SelectorBox/Split
@onready var selector: Control = $SelectorBox

var selected_drone: Drone
var selected_component: Node2D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
  pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
  pass

func _on_resolve_finish():
  state = State.DEFAULT
  pass

func focus_selection(drone: Drone, component:Node2D):
  if component is Joint:
    split_button.disabled = false
  else:
    split_button.disabled = true

  selected_drone = drone
  selected_component = component
  selector.position = get_viewport().get_mouse_position()

func defocus_selection():
  selector.position = Vector2(-1000, 0)
  state = State.DEFAULT

func _on_drone_click(drone:Drone, component: Node2D):
  if not drone in controller.commandables:
    return

  match state:
    State.DEFAULT:
      state = State.SELECTING
      focus_selection(drone, component)
    State.SELECTING:
      selected_drone = drone
      selected_component = component
      focus_selection(drone, component)
      # Move selection window..

func _on_resolve_click():
  state = State.DEFAULT
  controller.submit_command()
  resolve.emit()
  pass

func _on_split_click():
  controller.add_command(SplitCommand.new(selected_drone, selected_component))
  defocus_selection()