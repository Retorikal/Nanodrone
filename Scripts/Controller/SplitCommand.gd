extends Command
class_name SplitCommand

var split_target: Joint

func _init(drone: Drone, joint:Joint):
  target_drone = drone
  split_target = joint