extends Controller
class_name ControllerUI

var commands: Dictionary
var commandables: Array[Drone]

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
  pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
  pass

func prepare_controls(all_drones: Array[Drone], commandable_drones: Array[Drone]):
  clear_commands()
  commandables = commandable_drones
  
func add_command(command: Command):
  commands[command.target_drone] = command

func clear_commands():
  commands.clear()

func submit_command():
  var commands_value: Array[Command] = []
  for key in commands:
    commands_value.append(commands[key])

  print_debug("Submitting ", commands_value.size(), " commands")
  command_ready.emit(commands_value)
