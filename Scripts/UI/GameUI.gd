extends Node
class_name GameUI

signal resolve()

enum State{DEFAULT, SELECTING, SELECTING_MOVE, SELECTING_SPLIT, WAITING}

@export var controller: ControllerUI
@export var state: State = State.DEFAULT
@export var highlighter: Highlighter

@onready var split_button: Button = $UI/SelectorBox/Split
@onready var selector: Control = $UI/SelectorBox

var selected_drone: Drone

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
  selected_drone = drone
  selector.position = get_viewport().get_mouse_position()

func defocus_selection():
  selector.position = Vector2(-1000, 0)

func _on_drone_click(drone:Drone, component: Node2D):
  if not drone in controller.commandables:
    return

  match state:
    State.DEFAULT:
      state = State.SELECTING
      focus_selection(drone, component)
    State.SELECTING:
      selected_drone = drone
      split_button.disabled = drone.cell_dict.size() < 2
      focus_selection(drone, component)
    State.SELECTING_SPLIT:
      if not component is Joint:
        return
      
      controller.add_command(SplitCommand.new(selected_drone, component))
      highlighter.cleanup()
      state = State.DEFAULT

func _on_resolve_click():
  state = State.DEFAULT
  controller.submit_command()
  resolve.emit()
  pass

func _on_split_click():
  state = State.SELECTING_SPLIT
  highlighter.highlight_joints(selected_drone)
  defocus_selection()