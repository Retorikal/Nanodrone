extends Object
class_name NodePool

var template: PackedScene
var store: Array[Node2D]

func _init(t: PackedScene, size: int):
  template = t
  for i in range(size):
    store.push_back(template.instantiate())

func get_node():
  var obj = template.instantiate() if store.size() == 0 else store.pop_back()
  return obj

func return_node(obj: Node2D):
  store.push_back(obj)

func return_nodes(objs: Array[Node2D]):
  for obj in objs:
    store.push_back(obj)
