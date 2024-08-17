@tool
extends Node2D
class_name Drone

signal drone_split(drone: Drone)

@export var grid_pos: Vector2i

@export_category("Scenes")
@export var breakpoint_template: PackedScene

@export_category("Editor")
@export var click_to_realign_cells: bool:
  set(value):
    register_cells()
@export var size: int:
  get():
    return cell_dict.size()
@export var max_life: float:
  get():
    var life = 0
    for id in cell_dict:
      life += cell_dict[id].life
    return life

@onready var grid_stride: int = 36
@onready var cell_dict: Dictionary = Dictionary()
@onready var joint_dict: Dictionary = Dictionary()

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
  register_cells()

  if not Engine.is_editor_hint():
    register_joints()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
  position = position.lerp(grid_pos * grid_stride, 0.5);
  pass


func register_joints():
  for id in cell_dict:
    var cell: Cell = cell_dict[id]
    var potential_joint_ids: Array[Vector2i]
    if cell.connected_W:
      potential_joint_ids.append(id + Vector2i.UP)
    if cell.connected_A:
      potential_joint_ids.append(id + Vector2i.LEFT)
    if cell.connected_S:
      potential_joint_ids.append(id + Vector2i.DOWN)
    if cell.connected_D:
      potential_joint_ids.append(id + Vector2i.RIGHT)

    for potential_joint_id in potential_joint_ids:
      var key = Joint.get_key(id, potential_joint_id)
      if not cell_dict.has(potential_joint_id) or joint_dict.has(key):
        continue

      create_joint(cell_dict[id], cell_dict[potential_joint_id])

func create_joint(cell1: Cell, cell2: Cell) -> Joint:
  var joint: Joint = breakpoint_template.instantiate()
  joint.cell1 = cell1
  joint.cell2 = cell2
  joint.cell1.adjacents.append(cell2)
  joint.cell2.adjacents.append(cell1)
  joint.connect("request_break", self._on_break) # TODO: This should be managed by LevelManager
  joint_dict[joint.get_joint_key()] = joint
  add_child(joint)

  return joint

func delete_joint(joint: Joint):
  joint_dict.erase(joint.delete())
  return joint

func register_cells():
  cell_dict = Dictionary()

  # TODO: Round everything first

  for child in get_children():
    if child is Cell:
      child.position = child.grid_pos * grid_stride
      cell_dict[child.grid_pos] = child
  
  for id in cell_dict:
    var cell: Cell = cell_dict[id]
    if cell.connected_W:
      if cell_dict.has(id + Vector2i.UP):
        cell_dict[id + Vector2i.UP].connected_S = true
      else:
        cell.connected_W = false
    if cell.connected_A:
      if cell_dict.has(id + Vector2i.LEFT):
        cell_dict[id + Vector2i.LEFT].connected_D = true
      else:
        cell.connected_A = false
    if cell.connected_S:
      if cell_dict.has(id + Vector2i.DOWN):
        cell_dict[id + Vector2i.DOWN].connected_W = true
      else:
        cell.connected_S = false
    if cell.connected_D:
      if cell_dict.has(id + Vector2i.RIGHT):
        cell_dict[id + Vector2i.RIGHT].connected_A = true
      else:
        cell.connected_D = false
    pass


func _on_request_connect(cell: Cell, connect_cell: C.Dir, value: bool):
  pass

func _on_break(joint: Joint):
  print("I am at ", self, " and was called by ", joint)

  var split_cell_seed: Cell = joint.cell2
  delete_joint(joint)

  var explored_ids: Array[Vector2i] = []
  var unexplored_ids: Array[Vector2i] = [split_cell_seed.grid_pos]

  # Search all connected cell, store to array
  while (unexplored_ids.size() != 0):
    var exploring_id: Vector2i = unexplored_ids.pop_back()
    var exploring_cell: Cell = cell_dict[exploring_id]

    explored_ids.append(exploring_id)
    for cell in exploring_cell.adjacents:
      var candidate_id = cell.grid_pos
      if not explored_ids.has(candidate_id) and not unexplored_ids.has(candidate_id):
        unexplored_ids.append(cell.grid_pos)

  # Create clone
  var clone = Drone.new()
  clone.grid_stride = grid_stride
  clone.position = position
  clone.breakpoint_template = breakpoint_template
  for explored_id in explored_ids:
    var cell: Cell = cell_dict[explored_id]
    cell_dict.erase(explored_id)
    remove_child(cell)
    clone.add_child(cell)
  get_parent().add_child(clone)

  # Delete all orphaned joint
  for joint_id in joint_dict:
    print(joint_id)

  for joint_id in joint_dict.keys():
    print("attempting to delete ", joint_id)
    var checked_joint: Joint = joint_dict[joint_id]
    var joint_cell_id_1 = checked_joint.cell1.grid_pos
    var joint_cell_id_2 = checked_joint.cell2.grid_pos
    if not cell_dict.has(joint_cell_id_1) or not cell_dict.has(joint_cell_id_2):
      delete_joint(checked_joint)

  # Push clone and self away.
  var clone_size = explored_ids.size()
  var start_pos = grid_pos
  clone.grid_pos = start_pos + Vector2i.RIGHT
  grid_pos = start_pos + Vector2i.UP
  print("split weight is ", clone_size, size)

  pass
