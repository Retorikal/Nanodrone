@tool
extends Cell
class_name CellGun

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
  pass # Replace with function body.

func shoot():
  pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
  pass


func _on_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
  if event is InputEventMouseButton and event.is_pressed():
    cell_clicked.emit(self)
