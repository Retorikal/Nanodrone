extends Node
class_name Controller

signal command_ready(commands: Array[Command])

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
  pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
  pass

func prepare_controls(all_drones: Array[Drone], commandable_drones: Array[Drone]):
  pass

func get_mock_commands(drones: Array[Drone]):
  var commands: Array[Command]
  
  for drone in drones:
    var possible_joints = drone.joint_dict.keys()
    var target_joint = drone.joint_dict[possible_joints[1]]
    var new_command = SplitCommand.new(drone, target_joint)
    commands.append(new_command)
  return commands