@tool
extends Node2D
class_name LevelManager

signal drone_clicked(drone: Drone, node: Node2D)
signal resolve_finish()

enum State {PLANNING, MOVING}

@onready var SFXClick = $Drone/Click
@onready var SFXDamaged = $Drone/Damaged
@onready var SFXDetach = $Drone/Detach
@onready var SFXMove = $Drone/Move
@onready var SFXShoot = $Drone/Shoot

@export var region_bound_tl: Vector2i
@export var region_bound_br: Vector2i
@export var grid_stride: int = 36
@export var state: State = State.PLANNING
@export var user_con: Controller
@export var comp_con: Controller

var drones: Array[Drone]
var pending_commands: Dictionary

var valid_bbox: Rect2i:
  get():
    return Rect2i(region_bound_tl, region_bound_br + Vector2i.ONE - region_bound_tl)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
  if Engine.is_editor_hint():
    return

  for child in get_children():
    if child is Drone:
      register_drone(child)

  state = State.PLANNING
  user_con.connect("command_ready", self._on_command_ready)
  comp_con.connect("command_ready", self._on_command_ready)
  pool_command()

func _draw() -> void:
  var tl = Vector2(valid_bbox.position * grid_stride) - (Vector2.ONE * grid_stride * 0.5)
  var bound_rect = Rect2(tl, valid_bbox.size * grid_stride)
  draw_rect(bound_rect, Color.WHITE, false, 3)

  for i in range(1, valid_bbox.size.y):
    var bgn = Vector2(bound_rect.position.x, bound_rect.position.y + i * grid_stride)
    var end = Vector2(bound_rect.end.x, bound_rect.position.y + i * grid_stride)
    draw_line(bgn, end, Color.GRAY, .5, true)
    pass

  for i in range(1, valid_bbox.size.x):
    var bgn = Vector2(bound_rect.position.x + i * grid_stride, bound_rect.position.y)
    var end = Vector2(bound_rect.position.x + i * grid_stride, bound_rect.end.y)
    draw_line(bgn, end, Color.GRAY, .5, true)
    pass
  

func register_drone(drone: Drone):
  drone.connect("drone_split", self._on_drone_split)
  drone.connect("drone_destroyed", self._on_drone_destroyed)
  drone.connect("drone_body_clicked", self._on_drone_clicked)
  drone.connect("drone_joint_clicked", self._on_drone_clicked)
  drones.append(drone)

func pool_command():
  var user_drones: Array[Drone] = []
  var comp_drones: Array[Drone] = []

  pending_commands.clear()
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

  print("Resolving ", pending_commands.size(), " commands")

  for drone in resolvable_drones:
    if !pending_commands.has(drone):
      continue

    var command = pending_commands[drone]
    print("Doing ", resolvable_drones.size(), " ", command.target_drone, command.get_class())

    if command is MoveCommand:
      move_within_bounds(drone, command.move_target)

      if drone.is_moving:
        await drone.action_done

    if command is SplitCommand:
      var clone = drone.split(command.split_target)
      move_within_bounds(clone, clone.grid_pos)
      move_within_bounds(drone, drone.grid_pos)
      
      if drone.is_moving:
        await drone.action_done

      if clone.is_moving:
        await clone.action_done

      print(drone, clone)

  print("Command resolved! Waiting for new ones..")
  resolve_finish.emit()

func move_within_bounds(drone: Drone, target: Vector2i):
  var clamped_target = target
  var dpos = target - drone.grid_pos
  var target_pos_bbox = drone.global_bbox
  target_pos_bbox.position += dpos

  var dl = target_pos_bbox.position.x - valid_bbox.position.x
  var dr = valid_bbox.end.x - target_pos_bbox.end.x
  var dtop = target_pos_bbox.position.y - valid_bbox.position.y
  var dbot = valid_bbox.end.y - target_pos_bbox.end.y

  if dl < 0:
    clamped_target.x -= dl
  if dr < 0:
    clamped_target.x += dr
  if dtop < 0:
    clamped_target.y -= dtop
  if dbot < 0:
    clamped_target.y += dbot

  print(dl, " ", dr, " ", dtop, " ", dbot)
  SFXMove.play()

  drone.move(clamped_target)
  pass

func _on_drone_split(_drone: Drone, clone: Drone):
  register_drone(clone)
  SFXDetach.play()

func _on_drone_destroyed(drone: Drone):
  drones.erase(drone)

func _on_drone_clicked(drone: Drone, node: Node2D):
  drone_clicked.emit(drone, node)
  SFXClick.play()

func _on_command_ready(commands: Array[Command]):
  for command in commands:
    pending_commands[command.target_drone] = command
    print_debug("Command added for:", command.target_drone)

func _on_resolve():
  state = State.MOVING
  await resolve_commands()
  state = State.PLANNING
  pool_command()
