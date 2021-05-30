extends "res://src/scripts/SpaceBase.gd"

func UseQuatToRotate(x,y,z,w):
	"""
	Sign rules [-x]: (-) + (-) = + | (-) + (+) = - 
	"""
	var Origin = Vector3(transform.origin)
	var q = Quat(-x,y,z,w)
	var C = Basis(q)
	
	transform = Transform(C.x, C.y, C.z, Origin)
	
	.UseQuatToRotate(x, y, z, w)
