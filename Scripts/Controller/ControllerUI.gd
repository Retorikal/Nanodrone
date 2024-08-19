extends Controller
class_name ControllerUI

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
  pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
  pass

func prepare_controls(all_drones: Array[Drone], commandable_drones: Array[Drone]):
  var commands: Array[Command]
  
  for drone in commandable_drones:
    var possible_joints = drone.joint_dict.keys()
    var index:int = possible_joints.size/2
    var target_joint = drone.joint_dict[possible_joints[index]]
    commands.push_back(SplitCommand.new(drone, target_joint))
  pass