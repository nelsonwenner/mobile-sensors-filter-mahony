extends Spatial

var Axis = {"w": 0.5, "x": 0,"y": 0,"z": 0}

func UseQuatToRotate(x,y,z,w):
	"""
	Implementation
	"""

func _ready():
	Server.connect("data_proccessed", self, "_on_data_proccessed")

func _process(_delta):

	var x = Axis["x"]
	var y = Axis["y"]
	var z = Axis["z"]
	var w = Axis["w"]

	UseQuatToRotate(x,y,z,w)
	
func _on_data_proccessed(data):
	Axis = data
