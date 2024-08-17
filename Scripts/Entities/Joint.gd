extends Node2D
class_name Joint

signal request_break(joint: Joint)

@export var cell1: Cell
@export var cell2: Cell

static func get_key(pos1: Vector2i, pos2: Vector2i):
  var min_cell: Vector2i
  var max_cell: Vector2i

  if pos1.x != pos2.x:
    min_cell = pos1 if pos1.x < pos2.x else pos2
    max_cell = pos1 if pos1.x > pos2.x else pos2

  elif pos1.y != pos2.y:
    min_cell = pos1 if pos1.y < pos2.y else pos2
    max_cell = pos1 if pos1.y > pos2.y else pos2
  
  return str(min_cell) + str(max_cell)

func get_joint_key():
  return Joint.get_key(cell1.grid_pos, cell2.grid_pos);

func delete():
  var key = get_joint_key()
  cell1.adjacents.erase(cell2)
  cell2.adjacents.erase(cell1)
  queue_free()
  return key

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
  pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
  global_position = (cell1.global_position + cell2.global_position) / 2


func _on_area_2d_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
  if event is InputEventMouseButton and event.is_pressed():
    print("Joint ", get_joint_key(), " request break")
    request_break.emit(self)

func _on_area_2d_mouse_exited() -> void:
  pass # Replace with function body.

func _on_area_2d_mouse_entered() -> void:
  pass # Replace with function body.
