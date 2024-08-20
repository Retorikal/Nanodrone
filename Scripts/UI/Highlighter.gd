extends Node2D
class_name Highlighter

enum State {IDLE, HIGHLIGHT_MOVE, HIGHLIGHT_JOINT}

@export var dots: PackedScene
@export var state: State = State.IDLE

var highlighters: Array[Node2D] = []

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
  for i in range(100):
    highlighters.append(dots.instantiate())
  pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
  pass

func highlight_joints(drone: Drone):
  for joint_key in drone.joint_dict:
    var joint = drone.joint_dict[joint_key]
    var hl = highlighters.pop_back()
    add_child(hl)
    hl.global_position = joint.global_position
  pass

func cleanup():
  for child in get_children():
    remove_child(child)
    highlighters.append(child)
