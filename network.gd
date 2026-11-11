extends Node

# This script provides helpers for hosting, joining, and leaving a server.

# To get information about the network connection, use the "multiplayer"
# property local to a given node (since one Network can have both a client
# and server with different network connection properties).
# For example, "multiplayer.is_server()" and "multiplayer.get_unique_id()"

# To get information about the network game logic, use "Network.server_node"
# and "Network.client_node".
# For example, "Network.client_node.local_username"

var server := ENetMultiplayerPeer.new()
var client := ENetMultiplayerPeer.new()

var server_node: Server
var client_node: Client

func host_server(username: String, port: int) -> Error:

	# create a local server
	var result := server.create_server(port, 8)
	
	if result != Error.OK:
		return result
	
	# create a client to connect to the local server
	result = client.create_client("127.0.0.1", port)
	
	if result != Error.OK:
		server.close()
		return result
	
	# load the scene, waiting for both its children to enter the
	# tree (but not yet call _ready) so we can set them up
	get_tree().change_scene_to_file("res://scenes/networked.tscn")
	
	await get_tree().root.child_entered_tree
	await get_tree().current_scene.child_entered_tree
	await get_tree().current_scene.child_entered_tree
	
	server_node = get_tree().current_scene.get_node("Server")
	client_node = get_tree().current_scene.get_node("Client")
	
	_set_up_server_node()
	_set_up_client_node(username)
	
	return Error.OK

func join_server(username: String, address: String, port: int) -> Error:
	
	# create a client to connect to the remote server
	var result := client.create_client(address, port)
	
	if result != Error.OK:
		return result
	
	# load the scene, waiting for both its children to enter the
	# tree (but not yet call _ready) so we can set them up
	get_tree().change_scene_to_file("res://scenes/networked.tscn")
	
	await get_tree().root.child_entered_tree
	await get_tree().current_scene.child_entered_tree
	await get_tree().current_scene.child_entered_tree
	
	get_tree().current_scene.get_node("Server").queue_free()
	client_node = get_tree().current_scene.get_node("Client")
	
	_set_up_client_node(username)
	
	return Error.OK

func leave_server(reason: String = "") -> void:
	
	server_node = null
	client_node = null
	
	get_tree().change_scene_to_file("res://scenes/title.tscn")
	await get_tree().scene_changed
	
	client.close()
	server.close()
	
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	get_tree().current_scene.get_node("DisconnectReasonLabel").text = reason

func _set_up_server_node():
	
	# set up a multiplayer API for the server node and its descendents
	# (must set it before its descendents have a chance to run _ready)
	var api := SceneMultiplayer.new()
	api.multiplayer_peer = Network.server
	
	api.peer_connected.connect(server_node._on_peer_connected)
	api.peer_disconnected.connect(server_node._on_peer_disconnected)
	
	server_node.get_tree().set_multiplayer(api, server_node.get_path())

func _set_up_client_node(username: String):
	
	client_node.local_username = username
	
	# set up a multiplayer API for the client node and its descendents
	# (must set it before its descendents have a chance to run _ready)
	var api := SceneMultiplayer.new()
	api.multiplayer_peer = client
	
	api.peer_connected.connect(client_node._on_peer_connected)
	api.peer_disconnected.connect(client_node._on_peer_disconnected)
	api.connected_to_server.connect(client_node._on_connected_to_server)
	api.connection_failed.connect(client_node._on_connection_failed)
	api.server_disconnected.connect(client_node._on_server_disconnected)
	
	client_node.get_tree().set_multiplayer(api, client_node.get_path())
