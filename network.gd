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
	
	# load the scene
	get_tree().change_scene_to_file("res://scenes/networked.tscn")
	
	await get_tree().root.child_entered_tree
	await get_tree().current_scene.child_entered_tree
	await get_tree().current_scene.child_entered_tree
	
	server_node = get_tree().current_scene.get_node("Server")
	client_node = get_tree().current_scene.get_node("Client")
	
	_set_up_server_node(server_node)
	_set_up_client_node(client_node)
	client_node.local_username = username
	
	return Error.OK

func join_server(username: String, address: String, port: int) -> Error:
	
	# create a client to connect to the remote server
	var result := client.create_client(address, port)
	
	if result != Error.OK:
		return result
	
	# load the scene
	get_tree().change_scene_to_file("res://scenes/networked.tscn")
	
	await get_tree().root.child_entered_tree
	await get_tree().current_scene.child_entered_tree
	
	get_tree().current_scene.get_node("Server").queue_free()
	client_node = get_tree().current_scene.get_node("Client")
	
	_set_up_client_node(client_node)
	client_node.local_username = username
	
	return Error.OK

func leave_server(reason: String = "") -> void:
	
	get_tree().change_scene_to_file("res://scenes/title.tscn")
	await get_tree().scene_changed
	
	client.close()
	server.close()
	
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

	server_node = null
	client_node = null
	
	get_tree().current_scene.get_node("DisconnectReasonLabel").text = reason

func _set_up_client_node(THENODEOMG: Client):
	
	var api := SceneMultiplayer.new()
	api.multiplayer_peer = client
	
	api.peer_connected.connect(THENODEOMG._on_peer_connected)
	api.peer_disconnected.connect(THENODEOMG._on_peer_disconnected)
	api.connected_to_server.connect(THENODEOMG._on_connected_to_server)
	api.connection_failed.connect(THENODEOMG._on_connection_failed)
	api.server_disconnected.connect(THENODEOMG._on_server_disconnected)
	
	# use the new multiplayer API for this node and its descendants
	# this has to happen before its descendants have a chance to run
	# their _ready functions
	THENODEOMG.get_tree().set_multiplayer(api, THENODEOMG.get_path())

func _set_up_server_node(THENODEOMG: Server):
	
	var api := SceneMultiplayer.new()
	api.multiplayer_peer = Network.server
	
	api.peer_connected.connect(THENODEOMG._on_peer_connected)
	api.peer_disconnected.connect(THENODEOMG._on_peer_disconnected)
	
	# use the new multiplayer API for this node and its descendants
	# this has to happen before its descendants have a chance to run
	# their _ready functions
	THENODEOMG.get_tree().set_multiplayer(api, THENODEOMG.get_path())
