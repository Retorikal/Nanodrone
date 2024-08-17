@tool
extends Node2D
class_name Cell

signal request_connect(cell: Cell, connect_cell: C.Dir, value: bool)

@export var life: int = 2

@export_category("Editor")
@export var click_to_realign_cells: bool:
  set(value):
    if parent != null:
      parent.register_cells()

@export var connected_W: bool:
  set(value):
    connected_W = value
    _connect_cell(C.Dir.DIR_W, value)
@export var connected_A: bool:
  set(value):
    connected_A = value
    _connect_cell(C.Dir.DIR_A, value)
@export var connected_S: bool:
  set(value):
    connected_S = value
    _connect_cell(C.Dir.DIR_S, value)
@export var connected_D: bool:
  set(value):
    connected_D = value
    _connect_cell(C.Dir.DIR_D, value)

@export_category("Do Not Edit!")
@export var grid_pos: Vector2i

var parent: Drone = null
var adjacents: Array[Cell] = []

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
  pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
  pass

func _draw() -> void:
  if not Engine.is_editor_hint():
    return

  var line_dist = 20
  if connected_W:
    draw_line(Vector2.ZERO, Vector2.UP * line_dist, Color.ALICE_BLUE, 5)
  if connected_A:
    draw_line(Vector2.ZERO, Vector2.LEFT * line_dist, Color.ALICE_BLUE, 5)
  if connected_S:
    draw_line(Vector2.ZERO, Vector2.DOWN * line_dist, Color.ALICE_BLUE, 5)
  if connected_D:
    draw_line(Vector2.ZERO, Vector2.RIGHT * line_dist, Color.ALICE_BLUE, 5)

func _notification(what: int) -> void:
  if what == NOTIFICATION_LOCAL_TRANSFORM_CHANGED:
    var grid_pos_frac = position / parent.grid_stride;
    grid_pos = Vector2i(grid_pos_frac.round())

func _on_child_entered_tree(node: Node) -> void:
  var tmpParent = get_parent()

  if get_parent() is Drone:
    parent = tmpParent
    if !is_connected("request_connect", parent._on_request_connect):
      connect("request_connect", parent._on_request_connect)
  else:
    update_configuration_warnings()

  queue_redraw()

  set_notify_local_transform(true)
  pass # Replace with function body.

func _connect_cell(connect_dir: C.Dir, value: bool):
  queue_redraw()
  request_connect.emit(self, connect_dir, value)
  pass

func _get_configuration_warnings():
  var warnings = []

  if get_parent() is not Drone:
    warnings.append("Cell object must be parented to a Drone object")


  return warnings