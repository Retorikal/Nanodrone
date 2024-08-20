extends Node2D
class_name Highlighter

enum State {IDLE, HIGHLIGHT_MOVE, HIGHLIGHT_JOINT}

@export var dots: PackedScene
@export var state: State = State.IDLE

var hl_cells: Array[Node2D] = []
var used_hl_cells: Array[Node2D] = []
var hls: Array[Node2D]
var active_hl: Node2D
var click_position: Vector2
var selected_drone: Drone
var dgrid: Vector2i

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
  for i in range(300):
    hl_cells.append(dots.instantiate())
  pass # Replace with function body.

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

func add_highlighter_cell(hl: Node2D):
  var hl_cell = hl_cells.pop_back()
  used_hl_cells.append(hl_cell)
  hl.add_child(hl_cell)
  return hl_cell

func get_highlighter(drone: Drone):
  var hl = Node2D.new()
  add_child(hl)
  hl.global_position = drone.global_position
  hls.append(hl)
  return hl

func clear_highlighter(hl: Node2D):
  for cell in hl.get_children():
    hl.remove_child(cell)
    hl_cells.append(cell)

func highlight_joints(drone: Drone):
  state = State.HIGHLIGHT_JOINT
  active_hl = get_highlighter(drone)
  active_hl.global_position = drone.global_position
  for joint_key in drone.joint_dict:
    var joint = drone.joint_dict[joint_key]
    var hl_cell = add_highlighter_cell(active_hl)
    print("Moving to ", joint.global_position)
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
  active_hl = get_highlighter(drone)
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
  for hl in hls:
    clear_highlighter(hl)
    hl.queue_free()

  hls.clear()
