extends Command
class_name MoveCommand

var move_target: Vector2i

func _init(drone: Drone, move:Vector2i):
  target_drone = drone
  move_target = move