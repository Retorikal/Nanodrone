extends Command
class_name ShootCommand

var move_target: Vector2i

func _init(drone: Drone):
  target_drone = drone

func command_name() -> String:
  return "Shoot"