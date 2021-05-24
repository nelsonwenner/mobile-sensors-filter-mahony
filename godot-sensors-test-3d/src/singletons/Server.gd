extends Node

const PORT = 8080

var _server = WebSocketServer.new()

signal client_connected()
signal client_disconnected()
signal data_received()
signal data_proccessed(data)

func _ready():
	_server.set_bind_ip("0.0.0.0")
	
	_server.connect("client_connected", self, "_connected")
	_server.connect("client_disconnected", self, "_disconnected")
	_server.connect("data_received", self, "_on_data")

	var err = _server.listen(PORT)
	
	if err != OK:
		print("Unable to start server")
		set_process(false)
	else:
		print("Server started!")

func _process(delta):
	_server.poll()
	
func _connected(id, proto):
	print("client: ", id, proto)
	
func _disconnected(id, was_clean = false):
	print("closed: ", id, was_clean)

func _on_data(id):
	var payload = JSON.parse(_server.get_peer(id).get_packet().get_string_from_utf8()).result
	var formated = {"w": payload[0],"x": payload[1],"y": payload[2],"z": payload[3]}
	emit_signal("data_proccessed", formated)
