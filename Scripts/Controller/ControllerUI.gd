extends Controller
class_name ControllerUI

@onready var commands: Array[Command] = []
@onready var commandables: Array[Drone] = []

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
  pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
  pass

func prepare_controls(all_drones: Array[Drone], commandable_drones: Array[Drone]):
  commandables = commandable_drones
  
func submit_command():
  command_ready.emit(commands)
