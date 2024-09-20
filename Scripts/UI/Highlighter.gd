extends Node2D
class_name HighlighterManager

enum State {IDLE, HIGHLIGHT_MOVE, HIGHLIGHT_JOINT}

@export var joint_hl_cell: PackedScene
@export var move_hl_cell: PackedScene
@export var shoot_hl_cell: PackedScene
@export var state: State = State.IDLE
@onready var hl_cell_pools = {
  Highlighter.Type.MOVE: NodePool.new(move_hl_cell, 300),
  Highlighter.Type.JOINT: NodePool.new(joint_hl_cell, 300),
  Highlighter.Type.SHOOT: NodePool.new(joint_hl_cell, 0),
}

var hls: Dictionary
var active_hl: Node2D
var click_position: Vector2
var selected_drone: Drone
var dgrid: Vector2i

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
  match state:
    State.HIGHLIGHT_MOVE:
      var dmouse = get_viewport().get_mouse_position() - click_position
      var dgrid_frag = dmouse / selected_drone.grid_stride
      if dgrid_frag.length() > selected_drone.max_move_dist:
        dgrid_frag = dgrid_frag.normalized() * selected_drone.max_move_dist
      dgrid = round(dgrid_frag)
      var snap_position = (selected_drone.grid_pos + dgrid) * selected_drone.grid_stride
      active_hl.global_position = active_hl.global_position.lerp(snap_position, 0.5)
  pass

func add_highlighter_cell(hl: Highlighter):
  var hl_cell = hl_cell_pools[hl.type].get_node()
  hl.add_child(hl_cell)
  return hl_cell

func get_highlighter(drone: Drone, type: Highlighter.Type):
  var hl: Highlighter
  if drone in hls:
    hl = hls[drone]
    clear_highlighter(hl)
  else:
    hl = Highlighter.new()
    add_child(hl)

  hl.type = type
  hl.global_position = drone.global_position
  hls[drone] = hl
  return hl

func clear_highlighter(hl: Highlighter):
  for cell in hl.get_children():
    hl.remove_child(cell)
    hl_cell_pools[hl.type].return_node(cell)

func highlight_joints(drone: Drone):
  state = State.HIGHLIGHT_JOINT
  active_hl = get_highlighter(drone, Highlighter.Type.JOINT)
  active_hl.global_position = drone.global_position
  for joint_key in drone.joint_dict:
    var joint = drone.joint_dict[joint_key]
    var hl_cell = add_highlighter_cell(active_hl)
    hl_cell.global_position = joint.global_position
  pass

func highlight_joints_finalize(joint: Joint):
  clear_highlighter(active_hl)
  var hl = add_highlighter_cell(active_hl)
  hl.global_position = joint.global_position
  active_hl = null
  state = State.IDLE

func highlight_drone_spectre(drone: Drone):
  state = State.HIGHLIGHT_MOVE
  active_hl = get_highlighter(drone, Highlighter.Type.MOVE)
  selected_drone = drone
  click_position = get_viewport().get_mouse_position()
  for cell_key in drone.cell_dict:
    var cell = drone.cell_dict[cell_key]
    var hl_cell = add_highlighter_cell(active_hl)
    hl_cell.global_position = cell.global_position

func highlight_drone_spectre_finalize():
  active_hl = null
  state = State.IDLE

func wipe():
  for key in hls:
    var hl: Highlighter = hls[key]
    clear_highlighter(hl)
    hl.queue_free()

  hls.clear()
