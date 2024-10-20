@tool
extends Control
class_name TurnTrackerTile

@export var idle_color: Color
@export var select_color: Color

@export var health: float:
  set(val):
    health = val
    set_values()
@export var max_health: float:
  set(val):
    max_health = val
    set_values()
@export var move_dist: float:
  set(val):
    move_dist = val
    set_values()
@export var gun: int:
  set(val):
    gun = val
    set_values()
@export var command_name: String:
  set(val):
    command_name = val
    set_values()

@onready var command_display: Label = $MarginContainer/BoxContainer/HBoxContainer/Command
@onready var prop_display: Label = $MarginContainer/BoxContainer/HBoxContainer/Props
@onready var hp_display: TextureProgressBar = $MarginContainer/BoxContainer/HP
@onready var bg: ColorRect = $ColorRect

var update_deferred = false

func highlight(light: bool):
  var final_color = idle_color
  if light:
    final_color = select_color
  create_tween().tween_property(bg, "color", final_color, 0.2)

func set_values():
  if update_deferred:
    return

  if not update_deferred and not is_inside_tree():
    update_deferred = true
    await ready

  prop_display.text = "➠%.1f  🗡%s" % [move_dist, gun]
  command_display.text = command_name
  hp_display.max_value = max_health
  hp_display.value = health

  update_deferred = false
  pass

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
  pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
  pass
