extends Node2D
class_name LevelManager

enum State {PLANNING, MOVING}

@export var region_bound_tl: Vector2i
@export var region_bound_br: Vector2i
@export var grid_stride: int = 36
@export var state: State = State.PLANNING

var user_con: Controller
var comp_con: Controller
var drones: Array[Drone]
var pending_command: Dictionary

var valid_bbox: Rect2i:
  get():
    return Rect2i(region_bound_tl, region_bound_br + Vector2i.ONE - region_bound_tl)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
  for child in get_children():
    if child is Drone:
      drones.append(child)
  pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
  pass

func pool_command():
  var user_drones: Array[Drone] = []
  var comp_drones: Array[Drone] = []

  drones.sort_custom(sort_drones_mass_ascending)

  for drone in drones:
    if drone.player_owned:
      user_drones.append(drone)
    else:
      comp_drones.append(drone)

  user_con.prepare_controls(drones, user_drones)
  comp_con.prepare_controls(drones, comp_drones)
  
func sort_drones_mass_ascending(d1: Drone, d2: Drone):
  if d1.size < d2.size:
    return true
  
  if d1.player_owned:
    return true
  
  return false

func resolve_commands():
  var resolvable_drones = drones.duplicate(false)

  for drone in resolvable_drones:
    var command = pending_command[drone]

    if command is MoveCommand:
      move_within_bounds(drone, command.move_target)

      if !drone.is_queued:
        await drone.action_done

    if command is SplitCommand:
      var clone = drone.split(command.split_target)
      move_within_bounds(clone, clone.grid_pos)
      move_within_bounds(drone, drone.grid_pos) 
      
      if !drone.is_queued:
        await drone.action_done

      if !clone.is_queued:
        await clone.action_done

func move_within_bounds(drone: Drone, target: Vector2i):
  var clamped_target = target
  var dl = drone.global_bbox.position.x - valid_bbox.position.x 
  var dr = valid_bbox.end.x - drone.global_bbox.end.x
  var dtop = drone.global_bbox.position.y - valid_bbox.position.y
  var dbot = valid_bbox.end.y - drone.global_bbox.end.y

  if dl < 0:
    clamped_target.x -= dl
  if dr < 0:
    clamped_target.x += dr
  if dtop < 0:
    clamped_target.y -= dtop
  if dbot < 0:
    clamped_target.y += dbot

  drone.move(clamped_target)
  pass

func _on_command_ready(commands: Array[Command]):
  for command in commands:
    pending_command[command.target_drone] = command


