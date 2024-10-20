extends Node
class_name GameUI

signal resolve()

enum State {DEFAULT, SELECTING, SELECTING_MOVE, SELECTING_SPLIT, WAITING}

@export var controller: ControllerUI
@export var state: State = State.DEFAULT
@export var highlights_man: HighlighterManager
@export var tracker_tile: PackedScene

@onready var split_button: Button = $UI/SelectorBox/Split
@onready var selector: Control = $UI/SelectorBox

# These are initialized by _on_level_manager_round_start
@onready var tracker_sidebar: Control = $UI/Sidebar/TurnCycle
@onready var trackers: Dictionary = Dictionary()

var selected_drone: Drone

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
  pass # Replace with function body.

func focus_selection(drone: Drone, component: Node2D):
  selected_drone = drone
  selector.position = get_viewport().get_mouse_position()
  var selected_tile: TurnTrackerTile = trackers[selected_drone]
  selected_tile.highlight(true)

func defocus_selection():
  selector.position = Vector2(-1000, 0)

func register_command(command: Command):

  var tracker: TurnTrackerTile = trackers[command.target_drone]
  tracker.command_name = command.command_name()

  controller.add_command(command)
  pass

func reset_current_selection():
  state = State.DEFAULT
  defocus_selection()
  var selected_tile: TurnTrackerTile = trackers[selected_drone]
  selected_tile.highlight(false)

func _on_drone_click(drone: Drone, component: Node2D):
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
      if not component is Joint or not drone == selected_drone:
        return
      
      register_command(SplitCommand.new(selected_drone, component))
      highlights_man.highlight_joints_finalize(component)
      reset_current_selection()

func _on_resolve_click():
  reset_current_selection()
  highlights_man.wipe()
  controller.submit_command()
  resolve.emit()
  pass

func _on_split_click():
  state = State.SELECTING_SPLIT
  highlights_man.highlight_joints(selected_drone)
  defocus_selection()

func _on_move_click() -> void:
  state = State.SELECTING_MOVE
  highlights_man.highlight_drone_spectre(selected_drone)
  defocus_selection()
  pass # Replace with function body.

func _on_shoot_click() -> void:
  register_command(ShootCommand.new(selected_drone))
  highlights_man.highlight_drone_spectre_finalize()
  reset_current_selection()

func _on_level_manager_round_start(sorted_drones: Array[Drone]) -> void:
  # tracker_sidebar = $UI/Sidebar/TurnCycle
  for drone in trackers.keys():
    var tile = trackers[drone]
    tracker_sidebar.remove_child(tile)
    tile.queue_free()

  trackers.clear()

  for drone in sorted_drones:
    print("Adding tile for %d" % drone.max_move_dist)
    var tile: TurnTrackerTile = tracker_tile.instantiate()
    trackers[drone] = tile
    tile.health = drone.life
    tile.max_health = drone.max_life
    tile.move_dist = drone.max_move_dist
    tile.gun = drone.gun_count
    tracker_sidebar.add_child(tile)
    print("Added card..")
    
    if drone in controller.commandables:
      tile.command_name = "Idle"

    else:
      tile.command_name = "?"

    
func _input(event):
  # Mouse in viewport coordinates.
  match state:
    State.SELECTING_MOVE:
      if event is InputEventMouseButton and event.is_pressed():
        var target = selected_drone.grid_pos + highlights_man.dgrid
        register_command(MoveCommand.new(selected_drone, target))
        highlights_man.highlight_drone_spectre_finalize()
        reset_current_selection()
